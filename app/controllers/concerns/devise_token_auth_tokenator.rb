# Helper related to devise_auth_token tokens
module DeviseTokenAuthTokenator
  # Create a token (WARNING: while destroying other tokens)
  # and attach to response header
  #
  # @resource: ActiveRecord Model mounted with DeviseTokenAuth
  def generate_and_attach_session_token(resource)
    client_id = SecureRandom.urlsafe_base64(nil, false)
    token     = SecureRandom.urlsafe_base64(nil, false)

    resource.tokens = {
      client_id.to_s => {
        token: BCrypt::Password.create(token),
        expiry: (Time.zone.now + 10.years).to_i
      }
    }

    # Generate auth headers for response
    new_auth_header = resource.build_auth_header(token, client_id)

    # Save token
    resource.save!

    # Update response with the header that will be required by the next request
    response.headers.merge!(new_auth_header)
  end
end
