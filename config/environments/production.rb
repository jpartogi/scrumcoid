require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  #
  # Recommended for Fly.io:
  #   - :local     → uses persistent volume (current default, simple)
  #   - :tigris    → Fly's native S3-compatible storage (best for most Fly apps)
  #   - :r2        → Cloudflare R2
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym
  
  # Ensure local storage directory exists (only needed when using disk storage)
  if config.active_storage.service == :local
    config.after_initialize do
      storage_path = Rails.root.join("storage")
      FileUtils.mkdir_p(storage_path) unless Dir.exist?(storage_path)
    end
  end

  # Assume all access to the app is happening through a SSL-terminating reverse proxy (Fly.io does this).
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Trust the proxies we run behind (Fly/Thruster internal IPs + standard privates + localhost).
  # This improves request.remote_ip (used as fallback in our client_ip helper) and other Rails
  # IP-dependent behavior. Our visit tracking prefers explicit headers (CF-Connecting-IP etc.)
  # so this is defense-in-depth.
  config.action_dispatch.trusted_proxies = [
    "127.0.0.0/8", "::1",
    "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "169.254.0.0/16",
    "fc00::/7", "fe80::/10"
  ]

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :primary } }

  # When SOLID_QUEUE_IN_PUMA=true (default for simple deploys), Solid Queue runs
  # inside the web server process. Set to false when using a dedicated worker process.
  config.solid_queue.preserve_finished_jobs = false
  config.solid_queue.clear_finished_jobs_after = 1.week

  # Mailer configuration for Fly.io + Brevo
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  app_host = ENV.fetch("APP_HOST", "scrumcoid.fly.dev")

  config.action_mailer.default_url_options = {
    host: app_host,
    protocol: "https"
  }

  # Brevo SMTP (set BREVO_USERNAME + BREVO_PASSWORD via `fly secrets set`)
  if ENV["BREVO_USERNAME"].present?
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("BREVO_HOST", "smtp-relay.brevo.com"),
      port: ENV.fetch("BREVO_PORT", 587).to_i,
      domain: app_host.split(":").first, # strip port if present
      user_name: ENV["BREVO_USERNAME"],
      password: ENV["BREVO_PASSWORD"],
      authentication: :plain,
      enable_starttls_auto: true
    }
  end

  # Optional: Set a nice from address with name for better email presentation
  # (also set in ApplicationMailer and Devise initializer)
  if ENV["MAILER_FROM"].present?
    config.action_mailer.default_options = { from: ENV["MAILER_FROM"] }
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
