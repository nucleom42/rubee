module Rubee
  class AuthTokenMiddleware
    def initialize(app, req)
      @req = req
      @app = app
    end

    def call(env)
      # get token from header
      auth_header = headers(env)['HTTP_AUTHORIZATION']
      token = auth_header ? auth_header[/^Bearer (.*)$/]&.gsub('Bearer ', '') : nil
      # get token from cookies
      token ||= @req.cookies['jwt']
      if valid_token?(token)
        env['rack.session'] ||= {}
        env['rack.session']['authentificated'] = true
      end

      @app.call(env)
    end

    private

    def headers(env)
      env.each_with_object({}) { |(k, v), h| h[k] = v if k.start_with?('HTTP_') }
    end

    def valid_token?(token)
      return false unless token
      hash = decode_jwt(token)
      login_params = hash[:login]
      klass = hash[:klass]&.split('::')&.inject(Object) { |o, c| o.const_get(c) }

      klass&.where(login_params.transform_keys(&:to_sym))&.any?
    end

    def decode_jwt(token)
      decoded_array = begin
        ::JWT.decode(token, AuthTokenable::KEY, true, { algorithm: 'HS256' })
                      rescue StandardError
                        []
      end
      decoded_array&.first&.transform_keys(&:to_sym) || {} # Extract payload
    end
  end
end
