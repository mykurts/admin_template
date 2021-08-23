module ApplicationCable
  class Connection < ActionCable::Connection::Base
    ENCRYPTED_CHANNELS = Rails.configuration.settings[:encryption][:channels]
    def transmit(cable_message)
      if cable_message[:identifier]
        channel = JSON.parse(cable_message[:identifier])["channel"]
        if ENCRYPTED_CHANNELS.include?(channel) # Encrypt responses
          return websocket.transmit encrypt(encode(cable_message))
        end
      end
      websocket.transmit encode(cable_message)
    end
    def receive(websocket_message)
      # Get channel for unencrypted messages, throws ParserError for encrypted messages
      message = JSON.parse(websocket_message)
      channel = JSON.parse(message["identifier"])["channel"]
      # Only send the message if receiving channel is not encrypted
      unless ENCRYPTED_CHANNELS.include?(channel)
        send_async :dispatch_websocket_message, websocket_message
      end
      # JSON Parse error: maybe it was encrypted? decrypt and send it to the receiving channel
      rescue JSON::ParserError => e  
        send_async :dispatch_websocket_message, decrypt(websocket_message)
    end
    private
      def decrypt(body)
        AES256.decrypt(Base64.decode64(body), ::Rails.configuration.settings[:encryption][:key])
      end
      def encrypt(body)
        Base64.encode64(AES256.encrypt(body, ::Rails.configuration.settings[:encryption][:key]))
      end
  end
end