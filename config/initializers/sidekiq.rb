Sidekiq.configure_server do |config|
  config.redis = { url: Rails.configuration.settings[:redis][:redis_url] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.configuration.settings[:redis][:redis_url] }
end