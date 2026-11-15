require 'digest'
require 'securerandom'
require 'date'
require 'time'
require 'rack/request'

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
      req = Rack::Request.new(env)
      token ||= req.cookies['jwt'] || @req.cookies['jwt']

      if valid_token?(token)
        env['rack.session'] ||= {}
        env['rack.session']['authentificated'] = true
      else
        refreshed_headers = try_refresh(env)
        if refreshed_headers
          env['rubee.auth_refreshed_set_cookie'] = refreshed_headers['Set-Cookie'] || refreshed_headers['set-cookie']
        end
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

    def try_refresh(env)
      req = Rack::Request.new(env)
      raw = req.cookies[AuthTokenable::REFRESH_COOKIE] || @req.cookies[AuthTokenable::REFRESH_COOKIE]
      return nil unless raw

      AuthTokenable.ensure_refresh_tokens_table!
      row = Rubee::SequelObject::DB[:refresh_tokens].where(token_hash: AuthTokenable.refresh_token_hash(raw)).first
      return nil unless row
      return nil if row[:revoked_at]
      return nil if row[:expires_at] && Time.parse(row[:expires_at].to_s) < Time.now

      user_model = row[:user_class].to_s.split('::').inject(Object) { |o, c| o.const_get(c) }
      login_field = row[:login_field].to_sym
      login_value = row[:login_value]
      user = user_model.where(login_field => login_value).first
      return nil unless user

      # Rotate refresh token and issue new access token
      Rubee::SequelObject::DB[:refresh_tokens].where(id: row[:id]).update(revoked_at: Time.now, updated: Time.now)
      payload = { login: { login_field => login_value }, klass: user_model.name, exp: Time.now.to_i + AuthTokenable::EXPIRE }
      access = ::JWT.encode(payload, AuthTokenable::KEY, 'HS256')
      new_refresh = SecureRandom.hex(32)
      now = Time.now
      Rubee::SequelObject::DB[:refresh_tokens].insert(
        token_hash: AuthTokenable.refresh_token_hash(new_refresh),
        user_class: user_model.name,
        login_field: login_field.to_s,
        login_value: login_value.to_s,
        expires_at: now + AuthTokenable::REFRESH_EXPIRE,
        revoked_at: nil,
        created: now,
        updated: now
      )

      env['rack.session'] ||= {}
      env['rack.session']['authentificated'] = true

      {
        'Set-Cookie' => [
          "jwt=#{access}; path=/; httponly; secure",
          "#{AuthTokenable::REFRESH_COOKIE}=#{new_refresh}; path=/; httponly; secure"
        ]
      }
    rescue StandardError
      nil
    end

    def merge_set_cookie_headers(res_headers, extra_headers)
      return res_headers unless extra_headers && (extra_headers['Set-Cookie'] || extra_headers['set-cookie'])

      existing = res_headers['Set-Cookie'] || res_headers['set-cookie']
      merged = []
      case existing
      when Array
        merged.concat(existing.compact)
      when String
        merged.concat(existing.split("\n").compact)
      when nil
      else
        merged << existing.to_s
      end

      extra = extra_headers['Set-Cookie'] || extra_headers['set-cookie']
      case extra
      when Array
        merged.concat(extra.compact)
      when String
        merged.concat(extra.split("\n").compact)
      else
        merged << extra.to_s if extra
      end

      merged.reject! { |v| v.nil? || v == '' }
      res_headers.delete('set-cookie')
      res_headers['Set-Cookie'] = merged.length <= 1 ? merged.first : merged
      res_headers
    end
  end
end
