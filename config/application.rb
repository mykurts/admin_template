require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AdminTemplate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_job.queue_adapter = :sidekiq
    
    # Attach specific database if provided
    if ENV['RAILS_DATABASE_ENV'].present?
      self.paths['config/database'] = "config/database/#{ENV['RAILS_DATABASE_ENV']}.yml"
    end
      
    config.time_zone = 'Asia/Manila'

    # ENV configurables
    config.settings = YAML.load(ERB.new(File.read("#{Rails.root}/config/configurable.yml")).result).deep_symbolize_keys
    
    # Carrierwave
    config.carrierwave = YAML.load(ERB.new(File.read("#{Rails.root}/config/carrierwave.yml")).result).deep_symbolize_keys
    
    config.action_cable.allowed_request_origins = [/http:\/\/*/, /https:\/\/*/]
    config.action_cable.disable_request_forgery_protection = true
    
  end
end
