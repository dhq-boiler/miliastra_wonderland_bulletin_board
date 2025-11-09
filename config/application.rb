require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MiliastraWonderlandBulletinBoard
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
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # 日本語ロケール設定
    config.i18n.default_locale = :ja
    config.i18n.available_locales = [
      :ja,      # 日本語
      :'zh-CN', # 中国語簡体字
      :'zh-TW', # 中国語繁体字
      :en,      # 英語
      :ko,      # 韓国語
      :es,      # スペイン語
      :fr,      # フランス語
      :ru,      # ロシア語
      :th,      # タイ語
      :vi,      # ベトナム語
      :de,      # ドイツ語
      :id,      # インドネシア語
      :pt,      # ポルトガル語
      :tr,      # トルコ語
      :it       # イタリア語
    ]
    config.time_zone = "Tokyo"
  end
end
