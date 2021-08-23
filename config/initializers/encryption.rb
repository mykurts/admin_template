# Be sure to restart your server when you modify this file.
require 'protocol/encrypt_decrypt_inator'

if Rails.configuration.settings[:encryption][:enabled]
  Rails.application.config.middleware.use Protocol::EncryptDecryptInator::Adapter::Rails
end
