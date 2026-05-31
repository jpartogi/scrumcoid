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
    return if controller_path == "stripe_webhooks"

    ip_hash = Digest::SHA256.hexdigest(request.remote_ip)
    visited_on = Date.today

    UniqueVisit.create_or_find_by!(ip_hash: ip_hash, visited_on: visited_on)
  rescue => e
    logger.error "Failed to track unique visit: #{e.message}"
  end
end
