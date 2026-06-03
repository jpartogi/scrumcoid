class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :track_unique_visit
  helper_method :current_currency
  layout :determine_layout

  private

  def determine_layout
    if controller_path.start_with?("admin/") || (devise_controller? && current_user&.admin? && action_name.in?(%w[edit update]))
      "admin"
    else
      "application"
    end
  end

  def current_currency
    @current_currency ||= CurrencyResolver.new(request).currency
  end

  def authorize_admin!
    redirect_to root_path, alert: "Admin access is required." unless current_user&.admin?
  end

  def after_sign_in_path_for(resource)
    resource.admin? ? admin_root_path : dashboard_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def track_unique_visit
    return if controller_path.start_with?("admin/")
    return if devise_controller?
    return if request.path.start_with?("/rails/")

    return if bot?

    # Skip obvious non-human / infrastructure paths that shouldn't count as visits
    path = request.path.downcase
    return if path == "/robots.txt" || path == "/favicon.ico" ||
              path == "/icon.svg" || path.start_with?("/icon-") ||
              path == "/apple-touch-icon.png" || path == "/manifest.json" ||
              path.start_with?("/assets/") || path.start_with?("/packs/") ||
              path.start_with?("/up") || path == "/sitemap.xml"

    # --- Cookie-based visitor ID (primary for "unique" tracking) ---
    # A stable UUID per browser/device. Survives IP changes (NAT, mobile, VPN, office).
    # We hash it before storing (consistent with previous IP-hashing for privacy).
    # Falls back to IP hash only for clients that don't accept cookies (rare for real visitors).
    visitor_id = cookies.signed[:visitor_id]
    if visitor_id.blank?
      visitor_id = SecureRandom.uuid
      # permanent cookie (~20y expiry), httponly+secure for safety
      cookies.signed.permanent[:visitor_id] = {
        value: visitor_id,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax
      }
    end

    identifier = visitor_id.presence || client_ip.to_s
    fingerprint = Digest::SHA256.hexdigest(identifier)
    visited_on = Date.today

    UniqueVisit.create_or_find_by!(fingerprint: fingerprint, visited_on: visited_on)
  rescue => e
    logger.error "Failed to track unique visit: #{e.message}"
  end

  def client_ip
    # Proxy headers in decreasing order of trust/specificity.
    # These are set by Cloudflare, Fly.io/Thruster, and other common reverse proxies/CDNs.
    request.headers["CF-Connecting-IP"].presence ||
      request.headers["Fly-Client-IP"].presence ||
      request.headers["True-Client-IP"].presence ||
      request.headers["X-Real-IP"].presence ||
      # X-Forwarded-For is "client, proxy1, proxy2, ..."; leftmost is the original client.
      request.headers["X-Forwarded-For"].to_s.split(",").first&.strip.presence ||
      request.remote_ip
  end

  def bot?
    ua = request.user_agent.to_s
    return true if ua.blank?

    ua = ua.downcase
    # Broad but practical list of known crawlers, bots, monitors, fetchers, and tools.
    # Real visitors almost never match these.
    patterns = %w[
      bot crawler spider slurp googlebot bingbot baidu yandex duckduckbot
      facebookexternalhit linkedinbot twitterbot whatsapp telegrambot slackbot
      discordbot semrushbot ahrefsbot mj12bot dotbot rogerbot exabot ia_archiver
      applebot adsbot mediapartners-google feedfetcher-google
      rss validator checker scanner
      curl wget python requests urllib java okhttp axios node-fetch go-http-client
      httpie postman insomnia ruby
      uptime robot monitor pingdom statuscake datadog newrelic prtg
      headless phantomjs lighthouse pagespeed gtmetrix
    ]
    patterns.any? { |p| ua.include?(p) }
  end
end
