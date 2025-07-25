require_relative File.join(__dir__, 'middlewarable')
require 'date'

module Rubee
  module AuthTokenable
    KEY = "secret#{Date.today}".freeze unless defined?(KEY) # Feel free to cusomtize it
    EXPIRE = 3600 unless defined?(EXPIRE)

    def self.included(base)
      base.include(Middlewarable)
      base.include(InstanceMethods)
      base.extend(ClassMethods)

      base.attach('Rubee::AuthTokenMiddleware')
    end

    module InstanceMethods
      def authentificated?
        methods = self.class._auth_methods
        return true if methods && !methods.include?(@route[:action].to_sym)

        # This is suppose to be set in the middleware, otherwise it will return false
        valid_token?
      end

      def valid_token?
        @request.env['rack.session']&.[]('authentificated')
      end

      def authentificated_user
        # User model must be created with email and password properties at least
        if params[:email] && params[:password]
          @authentificated_user ||= ::User.where(email: params[:email], password: params[:password]).first
        elsif @request.cookies['jwt'] && valid_token?
          token = @request.cookies['jwt']
          hash = ::JWT.decode(token, Rubee::AuthTokenable::KEY, true, { algorithm: 'HS256' })
          @authentificated_user ||= ::User.where(email: hash[0]['username']).first
        end
      end

      def authentificate!
        return false unless authentificated_user

        # Generate token
        payload = { username: params[:email], exp: Time.now.to_i + EXPIRE }
        @token = ::JWT.encode(payload, KEY, 'HS256')
        # Set jwt token to the browser within cookie, so next browser request will include it.
        # make sure it passed to response_with headers options
        @token_header = { 'set-cookie' => "jwt=#{@token}; path=/; httponly; secure" }

        true
      end

      def unauthentificate!
        @request.env['rack.session']['authentificated'] = nil if @request.env['rack.session']&.[]('authentificated')
        @authehtificated_user = nil if @authehtificated_user
        @zeroed_token_header = {
          'set-cookie' => 'jwt=; path=/; httponly; secure; expires=thu, 01 jan 1970 00:00:00 gmt',
          'content-type' => 'application/json',
        }

        true
      end

      def handle_auth
        if authentificated?
          yield
        else
          response_with(type: :unauthentificated)
        end
      end
    end

    module ClassMethods
      def auth_methods(*args)
        @auth_methods ||= []
        @auth_methods.concat(args.map(&:to_sym)).uniq!

        @auth_methods.each do |method|
          around(method, :handle_auth)
        end
      end

      def _auth_methods
        @auth_methods || []
      end
    end
  end
end
