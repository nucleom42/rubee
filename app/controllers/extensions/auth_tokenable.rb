require_relative File.join(__dir__, 'middlewarable')

module Authable
  def self.included(base)
    base.include(Middlewarable)
    base.include(InstanceMethods)
    base.extend(ClassMethods)

    base.attach('AuthTokenMiddleware')
  end

  module InstanceMethods
    def authenticated?
      methods = self.class._auth_methods
      return true if methods && !methods.include?(@route[:action].to_sym)

      @request.env["rack.session"]&.[]("authenticated")
    end

    def authehticated_user
      @authehticated_user ||= User.where(email: @request.params[:email], password: @request.params[:password]).first
    end

    def authenticate!
    end
  end

  module ClassMethods
    def auth_methods(*args)
      @auth_methods ||= []
      @auth_methods.concat(args.map(&:to_sym)).uniq!
    end

    def _auth_methods
      @auth_methods || []
    end
  end
end
