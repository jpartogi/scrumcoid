require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative "local_env"
LocalEnv.load(
  File.expand_path("../.env", __dir__),
  File.expand_path("../.env.local", __dir__),
  File.expand_path("../.env.#{ENV.fetch('RAILS_ENV', 'development')}", __dir__)
)

module Scrumcoid
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # Store timestamps in UTC; reporting timezones (e.g. Australia/Brisbane) are applied at display time.
    config.time_zone = "UTC"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
