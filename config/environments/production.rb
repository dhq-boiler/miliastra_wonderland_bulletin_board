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
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]

  # Log to both STDOUT and file
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  else
    # Log to both file and STDOUT for better debugging
    file_logger = ActiveSupport::Logger.new(Rails.root.join("log", "production.log"), 1, 100.megabytes)
    stdout_logger = ActiveSupport::Logger.new(STDOUT)
    config.logger = ActiveSupport::BroadcastLogger.new(file_logger, stdout_logger)
    config.logger = ActiveSupport::TaggedLogging.new(config.logger)
  end

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Solid Queue, Cache, Cable are configured in config/initializers/solid_optional.rb
  # Set ENABLE_SOLID_QUEUE=true, ENABLE_SOLID_CACHE=true, ENABLE_SOLID_CABLE=true to enable them

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "miliastra-wonderland-bulletin-board.com"),
    protocol: "https"
  }

  # AWS SESを使用してメール送信
  # Custom AWS SES delivery method registered in config/initializers/aws_ses.rb
  # AWS SDK credentials should be set via ENV or IAM role
  if ENV["AWS_ACCESS_KEY_ID"].present?
    config.action_mailer.delivery_method = :aws_ses
  else
    # Fallback to SMTP if AWS credentials are not set
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: "localhost",
      port: 25,
      enable_starttls_auto: false
    }
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [
    "miliastra-wonderland-bulletin-board.com",     # Allow requests from main domain
    "www.miliastra-wonderland-bulletin-board.com", # Allow requests from www subdomain
    "52.197.165.60"                                # Allow direct IP access
  ]

  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
