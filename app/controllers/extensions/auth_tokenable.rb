require_relative File.join(__dir__, 'middlewarable')

module AuthTokenable
  KEY = "secret".freeze # Feel free to cusomtize it
  EXPIRE = 3600 # 1 hour

  def self.included(base)
    base.include(Middlewarable)
    base.include(InstanceMethods)
    base.extend(ClassMethods)

    base.attach('AuthTokenMiddleware')
  end

  module InstanceMethods
    def authentificated?
      methods = self.class._auth_methods
      return true if methods && !methods.include?(@route[:action].to_sym)
      # This is suppose to be set in the middleware, otherwise it will return false
      @request.env["rack.session"]&.[]("authentificated")
    end

    def authehticated_user
      # User model must be created with email and password properties at least
      @authehticated_user ||= User.where(email: params[:email], password: params[:password]).first
    end

    def log_in!
      return false unless authehticated_user

      # Generate token
      payload = { username: params[:email], exp: Time.now.to_i + EXPIRE }
      @token = JWT.encode(payload, KEY, 'HS256')

      true
    end

    def log_out!
      #TODO implement
    end

    def handle_auth
      if authentificated?
        yield
      else
        response_with type: :unauthentificated
      end
    end
  end

  module ClassMethods
    def auth_methods(*args)
      @auth_methods ||= []
      @auth_methods.concat(args.map(&:to_sym)).uniq!

      @auth_methods.each do |method|
        around method, :handle_auth
      end
    end

    def _auth_methods
      @auth_methods || []
    end
  end
end
