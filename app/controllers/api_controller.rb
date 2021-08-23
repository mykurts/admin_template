class ApiController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include DeviseTokenAuthTokenator
  include ClientCustomMessage
  include JsonTemplates

  rescue_from StandardError, with: :rescue_standard_error
  rescue_from ActionController::ParameterMissing, with: :rescue_param_missing
  rescue_from ActiveRecord::RecordNotFound, :with => :rescue_record_not_found
  rescue_from JSON::Schema::ValidationError, :with => :rescue_json_schema_error

  def render_success(json = {})
    render(status: 200, json: json.merge(status: 200))
  end

  # @json     : JSON data in Hash
  # @status   : Configure specific status
  #             [default] 400 (Let us assume all errors are the clients' fault)
  def render_error(json = {}, status = 400)
    render(status: 200, json: json.merge(status: status))
  end

  # Strict version of `render_error` where HTTP status is the same as JSON status
  def render_error!(json = {}, status = 400)
    render(status: status, json: json.merge(status: status))
  end

  # Trigger a bad request if a param is missing
  def params_required!(*args)
    args.each do |param|
      params.require(param)
    end
  end

  # TODO: Consolidate with `params_required!`
  def params_nested_required(args)
    args.each do |k, v|
      params.require(k)

      v.each do |item|
        params.require(k).require(item)
      end
    end
  end

  def validate_contact_number(contact)
    # Phonelib having trouble recognizing 09 inputs
    if contact.starts_with?('09')
      contact = contact[1..-1] # Trim 0
    end

    number = Phonelib.parse(contact)
    yield number.valid? && number.valid_for_country?("PH"), number.raw_national
  end

  private

    # Override `devise_token_auth`'s default unauthenticated response
    def render_authenticate_error
      return render_error!(compose_msg(:unauthorized), 401)
    end

    def rescue_standard_error(e)
      Rails.logger.error([e.message, e.backtrace].join("\n"))
      render_error(compose_msg(500), 500)
    end

    def rescue_param_missing(_e)
      render_error(compose_msg(:error, "Bad request!"), 400)
    end

    def rescue_record_not_found(_e)
      render_error(compose_msg(:error, "Not found!"), 404)
    end

    def rescue_json_schema_error(e)
      render_error(compose_msg(:error, "Bad request!").merge(error: "Invalid JSON schema"), 400)
    end
end
