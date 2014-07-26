require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myk
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Taipei'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = false   # set it to false to avoid a bug in I18n issue #13164

    config.generators do |g|
      g.test_framework      :mini_test, spec: true, fixture_replacement: :fabrication
      g.fixture_replacement :fabrication, dir: 'test/fabricators'
      g.stylesheets         false
      g.javascripts         false
      g.helpers             false
    end

    # precompile images for the support of bootstrap css
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
  end
end
