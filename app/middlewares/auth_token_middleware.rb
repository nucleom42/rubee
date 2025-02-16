class AuthTokenMiddleware
  def initialize(app, req)
    @app = app
    @token = Base64.encode64('secret').gsub(/\n/, '')
  end

  def call(env)
    auth_header = headers(env)["HTTP_AUTHORIZATION"]

    if valid_token?(auth_header)
      env["rack.session"] ||= {}
      env["rack.session"]["authenticated"] = true
    end

    @app.call(env)
  end

  private

  def headers(env)
    env.each_with_object({}) { |(k, v), h| h[k] = v if k.start_with?("HTTP_") }
  end

  def valid_token?(header)
    return false unless header

    header == "Bearer #{@token}"
  end
end
