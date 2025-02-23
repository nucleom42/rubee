class AuthTokenMiddleware
  def initialize(app, req)
    @app = app
  end

  def call(env)
    auth_header = headers(env)["HTTP_AUTHORIZATION"]
    token = auth_header ? auth_header[/^Bearer (.*)$/]&.gsub("Bearer ", "") : nil
    if valid_token?(token)
      env["rack.session"] ||= {}
      env["rack.session"]["authenticated"] = true
    end

    @app.call(env)
  end

  private

  def headers(env)
    env.each_with_object({}) { |(k, v), h| h[k] = v if k.start_with?("HTTP_") }
  end

  def valid_token?(token)
    return false unless token

    hash = decode_jwt(token)
    email = hash[:username]

    User.where(email:)&.any?
  end

  def decode_jwt(token)
    decoded_array = JWT.decode(token, AuthTokenable::KEY, true, { algorithm: 'HS256' })
    decoded_array&.first&.transform_keys(&:to_sym)  # Extract payload
  end
end
