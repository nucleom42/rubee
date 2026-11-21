require_relative File.join(__dir__, 'middlewarable')

module Rubee
  module AuthTokenable
    KEY = "secret#{ENV['JWT_KEY']}#{Date.today}".freeze unless defined?(KEY) # Feel free to cusomtize it
    EXPIRE = 3600 unless defined?(EXPIRE)
    REFRESH_EXPIRE = 2_592_000 unless defined?(REFRESH_EXPIRE) # 30 days
    REFRESH_COOKIE = 'rubee_refresh'.freeze unless defined?(REFRESH_COOKIE)
    REFRESH_SALT = "secret#{ENV['JWT_KEY']}refresh".freeze unless defined?(REFRESH_SALT)

    module_function

    def self.refresh_token_hash(raw)
      Digest::SHA256.hexdigest("#{REFRESH_SALT}#{raw}")
    end

    def self.ensure_refresh_tokens_table!
      CreateRefreshTokens.new.call
    end

    def self.included(base)
      base.include(Middlewarable)
      base.include(InstanceMethods)
      base.extend(ClassMethods)

      base.attach('Rubee::AuthTokenMiddleware')
      base.extend(SubclassHook)
    end

    module SubclassHook
      def inherited(subclass)
        super
        subclass.attach('Rubee::AuthTokenMiddleware')
      end
    end

    module InstanceMethods
      def authentificated?
        methods = self.class._auth_methods
        return true if methods && !methods.include?(@route[:action].to_sym)

        # This is suppose to be set in the middleware, otherwise it will return false
        valid_token?
      end

      # Backward-compatible alias
      def authenticated?
        authentificated?
      end

      def valid_token?
        @request.env['rack.session']&.[]('authentificated')
      end

      def authentificated_user(user_model: ::User, login: :email, password: :password)
        return @authentificated_user if defined?(@authentificated_user) && @authentificated_user

        if params[login] && params[password]
          query_params = { login => params[login], password => params[password] }
          @authentificated_user = user_model.find_first(query_params)
          return @authentificated_user
        end

        return nil unless valid_token?

        if @request.cookies['jwt']
          begin
            token = @request.cookies['jwt']
            hash = ::JWT.decode(token, Rubee::AuthTokenable::KEY, true, { algorithm: 'HS256' })
            login_value = hash[0]["login"][login.to_s]
            @authentificated_user = user_model.find_first(login => login_value).first if login_value
            return @authentificated_user if @authentificated_user
          rescue StandardError
            nil
          end
        end

        # Fallback: resolve from valid refresh token (e.g. after seamless refresh)
        begin
          ensure_refresh_tokens_table!
          if (refresh_token_string = @request.cookies[REFRESH_COOKIE])
            refresh_token_record = Rubee::SequelObject::DB[:refresh_tokens]
              .where(token_hash: refresh_token_hash(refresh_token_string)).first || {}
            if refresh_token_record[:revoked_at].nil? &&
                (refresh_token_record[:expires_at].nil? || Time.parse(refresh_token_record[:expires_at].to_s) >= Time.now)
              klass = refresh_token_record[:user_class].to_s.split('::').inject(Object) { |o, c| o.const_get(c) }
              field = (refresh_token_record[:login_field] || login).to_sym
              @authentificated_user = klass.where(field => refresh_token_record[:login_value]).first
            end
          end
        rescue StandardError
          nil
        end

        @authentificated_user
      end

      # Backward-compatible alias
      def authenticated_user(**args)
        authentificated_user(**args)
      end

      def authentificate!(user_model: ::User, login: :email, password: :password)
        user = authentificated_user(user_model:, login:, password:)
        return false unless user

        issue_access_token!(user:, user_model:, login:)
        issue_refresh_token!(user:, user_model:, login:)
        set_auth_headers!

        true
      end

      # Backward-compatible alias
      def authenticate!(**args)
        authentificate!(**args)
      end

      def unauthentificate!(user_model: ::User, login: :email, password: :password)
        revoke_refresh_token_from_request!
        @request.env['rack.session']['authentificated'] = nil if @request.env['rack.session']&.[]('authentificated')
        remove_instance_variable(:@authentificated_user) if defined?(@authentificated_user)
        remove_instance_variable(:@authenticated_user) if defined?(@authenticated_user)
        @token = nil
        @refresh_token = nil
        set_zeroed_auth_headers!

        true
      end

      # Backward-compatible alias
      def unauthenticate!(**args)
        unauthentificate!(**args)
      end

      def handle_auth
        if authentificated?
          yield
        else
          response_with(type: :unauthentificated)
        end
      end

      private

      def issue_access_token!(user:, user_model:, login:)
        login_value = params[login] || user.send(login)
        payload = { login: { login => login_value }, klass: user_model.name, exp: Time.now.to_i + EXPIRE }
        @token = ::JWT.encode(payload, KEY, 'HS256')
      end

      def issue_refresh_token!(user:, user_model:, login:)
        ensure_refresh_tokens_table!
        raw = SecureRandom.hex(32)
        now = Time.now
        login_value = (params[login] || user.send(login)).to_s
        Rubee::SequelObject::DB[:refresh_tokens].insert(
          token_hash: refresh_token_hash(raw),
          user_class: user_model.name,
          login_field: login.to_s,
          login_value: login_value,
          expires_at: now + REFRESH_EXPIRE,
          revoked_at: nil,
          created: now,
          updated: now
        )
        @refresh_token = raw
      rescue StandardError => e
        # Keep access-token flow working even if refresh persistence is unavailable.
        Rubee::Logger.error(message: "Refresh token issue failed: #{e.message}") if defined?(Rubee::Logger)
        @refresh_token = nil
      end

      def refresh_access_token!
        ensure_refresh_tokens_table!
        raw = @request.cookies[REFRESH_COOKIE]
        return false unless raw

        row = Rubee::SequelObject::DB[:refresh_tokens].where(token_hash: refresh_token_hash(raw)).first
        return false unless row
        return false if row[:revoked_at]
        return false if row[:expires_at] && Time.parse(row[:expires_at].to_s) < Time.now

        user_model = row[:user_class].to_s.split('::').inject(Object) { |o, c| o.const_get(c) }
        login_field = row[:login_field].to_sym
        login_value = row[:login_value]
        user = user_model.where(login_field => login_value).first
        return false unless user

        # Rotate refresh token
        Rubee::SequelObject::DB[:refresh_tokens].where(id: row[:id]).update(revoked_at: Time.now, updated: Time.now)
        payload = { login: { login_field => login_value }, klass: user_model.name, exp: Time.now.to_i + EXPIRE }
        @token = ::JWT.encode(payload, KEY, 'HS256')
        issue_refresh_token!(user:, user_model:, login: login_field)
        @request.env['rack.session'] ||= {}
        @request.env['rack.session']['authentificated'] = true
        set_auth_headers!
        true
      rescue StandardError => e
        Rubee::Logger.error(message: "Refresh token refresh failed: #{e.message}") if defined?(Rubee::Logger)
        false
      end

      def revoke_refresh_token_from_request!
        ensure_refresh_tokens_table!
        raw = @request.cookies[REFRESH_COOKIE]
        return unless raw

        Rubee::SequelObject::DB[:refresh_tokens]
          .where(token_hash: refresh_token_hash(raw), revoked_at: nil)
          .update(revoked_at: Time.now, updated: Time.now)
      rescue StandardError
        nil
      end

      def set_auth_headers!
        cookies = []
        cookies << "jwt=#{@token}; path=/; httponly; secure" if @token
        cookies << "#{REFRESH_COOKIE}=#{@refresh_token}; path=/; httponly; secure" if @refresh_token
        @token_header = { 'Set-Cookie' => cookies.length == 1 ? cookies.first : cookies }
        @auth_headers = @token_header
      end

      def set_zeroed_auth_headers!
        expired = 'thu, 01 jan 1970 00:00:00 gmt'
        cookies = [
          "jwt=; path=/; httponly; secure; expires=#{expired}",
          "#{REFRESH_COOKIE}=; path=/; httponly; secure; expires=#{expired}",
        ]
        @zeroed_token_header = {
          'Set-Cookie' => cookies,
          'content-type' => 'application/json',
        }
        @auth_headers = @zeroed_token_header
      end

      def refresh_token_hash(raw)
        Digest::SHA256.hexdigest("#{REFRESH_SALT}#{raw}")
      end

      def ensure_refresh_tokens_table!
        db = Rubee::SequelObject::DB
        return if db.tables.include?(:refresh_tokens)

        db.create_table(:refresh_tokens) do
          primary_key(:id)
          String(:token_hash, null: false, unique: true)
          String(:user_class, null: false)
          String(:login_field, null: false)
          String(:login_value, null: false)
          DateTime(:expires_at, null: false)
          DateTime(:revoked_at)
          DateTime(:created)
          DateTime(:updated)
          index(:token_hash)
          index(:user_class)
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
