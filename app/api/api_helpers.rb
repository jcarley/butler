module APIHelpers

  TOKEN_REGEX = /^Token /
  AUTHN_PAIR_DELIMITERS = /(?:,|;|\t+)/

  def logger
    BaseAPI.logger
  end

  # authentication

  def authenticate!
    unauthorized! unless current_user
  end

  def current_user
    @current_user ||= authenticate_with_http_token
  end

  def authenticate_with_http_token
    token = user_token(headers)
    getty_token = Security::GettyToken.new(token)

    user ||= User.find_by(:integration_id => getty_token.account_id)

    if user.present?
      user = nil unless user.enabled?
    end

    return user
  end

  # parameters

  def attributes_for_group(group)
    strong_params = StrongParameters.new(route, group)
    strong_params.permit!(params)
  end

  # errors

  def unauthorized!
    render_api_error!('401 Unauthorized', 401)
  end

  def render_api_error!(message, status)
    error!({'message' => message}, status)
  end

  # tokens

  def user_token(headers)
    token_header = CGI::unescape(headers["Authorization"])
    params_and_options = token_params_from(token_header)
    token_and_options = [params_and_options.shift.last, Hash[params_and_options].with_indifferent_access]
    token_and_options[0]
  end

  def token_params_from(auth)
    rewrite_param_values params_array_from raw_params auth
  end

  def rewrite_param_values(array_params)
    array_params.each { |param| param.last.gsub! %r/^"|"$/, '' }
  end

  def params_array_from(raw_params)
    raw_params.map { |param| param.split %r/=(.+)?/ }
  end

  def raw_params(auth)
    auth.sub(TOKEN_REGEX, '').split(/"\s*#{AUTHN_PAIR_DELIMITERS}\s*/)
  end

end
