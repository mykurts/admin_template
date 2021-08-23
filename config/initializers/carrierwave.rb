# https://github.com/carrierwaveuploader/carrierwave#activerecord
require 'carrierwave/orm/activerecord'

# https://github.com/carrierwaveuploader/carrierwave#configuring-carrierwave
CarrierWave.configure do |config|
  # Fallback asset hosts
  asset_host = ENV['RAILS_CARRIERWAVE_ASSET_HOST'].presence || 'http://localhost:3000'

  # NOTE: Defaults to file storage
  case ENV['RAILS_CARRIERWAVE_STORAGE'].to_s.to_sym
  when :fog
    config.storage = :fog
    config.asset_host = asset_host
    config.fog_provider = 'fog/aws'
    config.fog_attributes = { 'Cache-Control'=>'max-age=315576000' }
    config.fog_credentials = Rails.configuration.carrierwave[:credentials]
    config.fog_directory = Rails.configuration.carrierwave[:directory]
  else
    config.storage = :file
    config.asset_host = asset_host

    # Defaults to `Rails.root + 'public/uploads'` if omitted
    if ENV['RAILS_CARRIERWAVE_FILE_ROOT'].present?
      config.root = ENV['RAILS_CARRIERWAVE_FILE_ROOT']
    end
  end
end
