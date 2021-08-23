module Protocol
  module EncryptDecryptInator
    module Adapter
      # Use as Rack middleware
      class Rails
        def initialize(app)
          @app = app
        end

        def call(env)
          request = Rack::Request.new(env)
          if env['CONTENT_TYPE'].present?
            # Encrypt API routes only
            if request.path[0..3].eql?('/v1/') || request.path[0..3].eql?('/v2/') || request.path[0..3].eql?('/v3/')
              
              if request.content_type.include?('application/json')
                return [400, { 'Content-Type' => 'application/json' }, [{ error: 'Invalid Request' }.to_json]]
              elsif request.content_type.include?('text/plain')
                decrypted_body = decrypt(env['rack.input'].read)
                JSON.parse(decrypted_body).each do |key, value|
                  request.update_param(key, value)
                end
                env['rack.input'].rewind
              elsif request.content_type.include?('multipart/form-data')
                decrypted_body = decrypt(request.params['payload'])
                JSON.parse(decrypted_body).each do |key, value|
                  if value.is_a?(Hash) && request.params[key].present?
                    request.update_param(key, value.merge(request.params[key]))
                  else
                    request.update_param(key, value)
                  end
                end
              end
            end
          end
          status, headers, response = @app.call(env)
          # Encrypt if response is json
          if request.path[0..3].eql?('/v3/') && headers['Content-Type'].present? && headers['Content-Type'].include?('application/json') || request.path[0..3].eql?('/v1/') && headers['Content-Type'].present? && headers['Content-Type'].include?('application/json') || request.path[0..3].eql?('/v2/') && headers['Content-Type'].present? && headers['Content-Type'].include?('application/json')

            encrypted_response = encrypt(response.body)
            headers['Content-Length'] = encrypted_response.length.to_s
            headers['Content-Type'] = 'text/plain'
            [status, headers, [encrypted_response]]
          else
            [status, headers, response]
          end
        end

        def decrypt(body)
          AES256.decrypt(Base64.decode64(body), ::Rails.configuration.settings[:encryption][:key])
        end

        def encrypt(body)
          Base64.encode64(AES256.encrypt(body, ::Rails.configuration.settings[:encryption][:key]))
        end
      end
    end
  end
end
