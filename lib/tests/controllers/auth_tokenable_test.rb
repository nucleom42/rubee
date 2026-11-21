require_relative '../test_helper'
require 'jwt'

class TestController < Rubee::BaseController
  auth_methods(:show)
  def show
    response_with(type: :json, object: { ok: :ok })
  end

  # POST /test/login (login logic)
  def login
    if authentificate! # AuthTokenable method that init @token_header
      # Redirect to restricted area, make sure headers: @token_header is passed
      response_with(type: :json, object: { ok: :ok }, headers: @token_header)
    else
      @error = "Wrong email or password"
      response_with(type: :json, object: { error: 'user unauthenticated' }, status: :unauthenticated)
    end
  end

  # POST /test/logout (logout logic)
  def logout
    unauthentificate! # AuthTokenable method aimed to handle logout action.
    # Make sure @zeroed_token_header is paRssed within headers options
    response_with(type: :json, object: { ok: 'logged out' }, headers: @zeroed_token_header)
  end
end

class TesttwoController < Rubee::BaseController
  auth_methods(:show)
  def show
    response_with(type: :json, object: { ok: :ok })
  end

  # POST /testtwo/login (login logic)
  def login
    if authentificate!(user_model: Client, login: :name, password: :digest_password)
      response_with(type: :json, object: { ok: :ok }, headers: @token_header)
    else
      @error = "Wrong email or password"
      response_with(type: :json, object: { error: 'user unauthenticated' }, status: :unauthenticated)
    end
  end

  # POST /testtwo/logout (logout logic)
  def logout
    unauthentificate!(user_model: Client, login: :name, password: :digest_password)
    response_with(type: :json, object: { ok: 'logged out' }, headers: @zeroed_token_header)
  end
end

class AuthTokenableTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def setup
    Rubee::Autoload.call
    ensure_refresh_tokens_table!
    clear_auth_data!

    Rubee::Router.draw do |route|
      route.post('/test/login', to: 'test#login')
      route.post('/test/logout', to: 'test#logout')
      route.get('/test/show', to: 'test#show')
      route.post('/testtwo/login', to: 'testtwo#login')
      route.post('/testtwo/logout', to: 'testtwo#logout')
      route.get('/testtwo/show', to: 'testtwo#show')
    end
    User.create(email: '9oU8S@example.com', password: '123456')
    Client.create(name: '9o@example.com', digest_password: '123456')
  end

  def teardown
    clear_auth_data! if defined?(Rubee::SequelObject) && Rubee::SequelObject::DB
  end

  def test_test_controller_auth_tokenable
    get('/test/show')

    assert_equal(401, last_response.status)
  end

  def test_test_controller_tokenable_authenticated
    post('/test/login', { email: '9oU8S@example.com', password: '123456' })
    rack_mock_session.cookie_jar["jwt"] = cookie_value('jwt')

    get('/test/show')

    assert_equal(200, last_response.status)
  end

  def test_test_controller_included_auth_tokenable_unauthenticated_custom_model
    get('/testtwo/show')

    assert_equal(401, last_response.status)
  end

  def test_test_controller_authenticated_custom_model
    post('/testtwo/login', { name: '9o@example.com', digest_password: '123456' })
    rack_mock_session.cookie_jar["jwt"] = cookie_value('jwt')

    get('/testtwo/show')

    assert_equal(200, last_response.status)
  end

  def test_login_issues_refresh_token_cookie_and_persists_db_record
    post('/test/login', { email: '9oU8S@example.com', password: '123456' })

    assert_equal(200, last_response.status)
    refute_nil(cookie_value('jwt'))
    refute_nil(cookie_value('rubee_refresh'))

    assert_equal(1, Rubee::SequelObject::DB[:refresh_tokens].count)
    row = Rubee::SequelObject::DB[:refresh_tokens].first
    assert_equal('User', row[:user_class])
    assert_equal('email', row[:login_field])
    assert_equal('9oU8S@example.com', row[:login_value])
    assert_nil(row[:revoked_at])
  end

  def test_auto_refreshes_access_token_with_valid_refresh_cookie
    post('/test/login', { email: '9oU8S@example.com', password: '123456' })
    old_refresh = cookie_value('rubee_refresh')
    expired_jwt = expired_jwt_for(email: '9oU8S@example.com', klass: 'User')

    clear_cookies
    rack_mock_session.cookie_jar['jwt'] = expired_jwt
    rack_mock_session.cookie_jar['rubee_refresh'] = old_refresh

    get('/test/show')

    assert_equal(200, last_response.status)
    refute_nil(cookie_value('jwt'))
    refute_nil(cookie_value('rubee_refresh'))
    refute_equal(expired_jwt, cookie_value('jwt'))
    refute_equal(old_refresh, cookie_value('rubee_refresh'))
    assert_equal(2, Rubee::SequelObject::DB[:refresh_tokens].count)
    assert_equal(1, Rubee::SequelObject::DB[:refresh_tokens].where { revoked_at !~ nil }.count)
  end

  def test_invalid_refresh_token_does_not_authenticate_when_access_expired
    post('/test/login', { email: '9oU8S@example.com', password: '123456' })
    expired_jwt = expired_jwt_for(email: '9oU8S@example.com', klass: 'User')

    clear_cookies
    rack_mock_session.cookie_jar['jwt'] = expired_jwt
    rack_mock_session.cookie_jar['rubee_refresh'] = 'invalid-refresh-token'

    get('/test/show')

    assert_equal(401, last_response.status)
  end

  def test_logout_revokes_refresh_token_and_clears_cookies
    post('/test/login', { email: '9oU8S@example.com', password: '123456' })
    jwt = cookie_value('jwt')
    refresh = cookie_value('rubee_refresh')
    rack_mock_session.cookie_jar['jwt'] = jwt
    rack_mock_session.cookie_jar['rubee_refresh'] = refresh

    post('/test/logout')

    assert_equal(200, last_response.status)
    row = Rubee::SequelObject::DB[:refresh_tokens].first
    refute_nil(row[:revoked_at])

    expired_jwt = expired_jwt_for(email: '9oU8S@example.com', klass: 'User')
    clear_cookies
    rack_mock_session.cookie_jar['jwt'] = expired_jwt
    rack_mock_session.cookie_jar['rubee_refresh'] = refresh
    get('/test/show')

    assert_equal(401, last_response.status)
  end

  def test_custom_model_login_refresh_and_rotation
    post('/testtwo/login', { name: '9o@example.com', digest_password: '123456' })
    old_refresh = cookie_value('rubee_refresh')
    expired_jwt = expired_jwt_for(login_field: :name, login_value: '9o@example.com', klass: 'Client')

    clear_cookies
    rack_mock_session.cookie_jar['jwt'] = expired_jwt
    rack_mock_session.cookie_jar['rubee_refresh'] = old_refresh

    get('/testtwo/show')

    assert_equal(200, last_response.status)
    refute_nil(cookie_value('rubee_refresh'))
    refute_equal(old_refresh, cookie_value('rubee_refresh'))
    row = Rubee::SequelObject::DB[:refresh_tokens].order(:id).last
    assert_equal('Client', row[:user_class])
    assert_equal('name', row[:login_field])
  end

  def test_refresh_token_extends_session_beyond_access_token_expiry_integration
    post('/test/login', { email: '9oU8S@example.com', password: '123456' })
    assert_equal(200, last_response.status)

    original_access = cookie_value('jwt')
    refresh_cookie = cookie_value('rubee_refresh')
    refute_nil(original_access)
    refute_nil(refresh_cookie)

    # Access token is short-lived (original token lifetime), refresh token lasts much longer.
    access_payload = JWT.decode(original_access, Rubee::AuthTokenable::KEY, true, { algorithm: 'HS256' }).first
    access_ttl = access_payload['exp'].to_i - Time.now.to_i
    refresh_row = Rubee::SequelObject::DB[:refresh_tokens].order(:id).last
    refresh_ttl = Time.parse(refresh_row[:expires_at].to_s).to_i - Time.now.to_i

    assert_operator(access_ttl, :<=, Rubee::AuthTokenable::EXPIRE)
    assert_operator(refresh_ttl, :>, Rubee::AuthTokenable::EXPIRE)
    assert_operator(refresh_ttl, :>, access_ttl)

    # Simulate original access token expiration: protected controller action should still succeed
    # transparently via DB-backed refresh token, proving session is extended beyond access expiry.
    expired_access = expired_jwt_for(email: '9oU8S@example.com', klass: 'User')
    clear_cookies
    rack_mock_session.cookie_jar['jwt'] = expired_access
    rack_mock_session.cookie_jar['rubee_refresh'] = refresh_cookie

    get('/test/show')

    assert_equal(200, last_response.status)
    rotated_access = cookie_value('jwt')
    rotated_refresh = cookie_value('rubee_refresh')
    refute_nil(rotated_access)
    refute_nil(rotated_refresh)
    refute_equal(expired_access, rotated_access)
    refute_equal(refresh_cookie, rotated_refresh)

    # Rotated/active refresh token remains persisted and valid for future requests.
    active_refresh = Rubee::SequelObject::DB[:refresh_tokens].where(revoked_at: nil).order(:id).last
    refute_nil(active_refresh)
    assert_operator(Time.parse(active_refresh[:expires_at].to_s), :>, Time.now)
  end

  private

  def ensure_refresh_tokens_table!
    Rubee::AuthTokenable.ensure_refresh_tokens_table!
  end

  def clear_auth_data!
    Rubee::SequelObject::DB[:refresh_tokens].delete if Rubee::SequelObject::DB.tables.include?(:refresh_tokens)
    User.dataset.delete if Rubee::SequelObject::DB.tables.include?(:users)
    Client.dataset.delete if defined?(Client) && Rubee::SequelObject::DB.tables.include?(:clients)
    clear_cookies
  rescue StandardError
    clear_cookies
  end

  def cookie_value(name)
    c = last_response.cookies[name]
    if c
      val = c.respond_to?(:value) ? c.value.last : c
      return val unless val.nil? || val == ''
    end

    headers = last_response.headers
    set_cookie = headers['Set-Cookie'] || headers['set-cookie']
    cookies = case set_cookie
              when Array then set_cookie.flat_map { |v| v.to_s.split("\n") }
              when String then set_cookie.split("\n")
              else []
              end
    # Some adapters may join multiple cookies differently; do a broad scan.
    cookies = [set_cookie].compact if cookies.empty? && set_cookie
    cookies.flatten.each do |cookie|
      str = cookie.to_s
      if str =~ /(?:^|,\s*)#{Regexp.escape(name)}=([^;,\s]*)/
        return Regexp.last_match(1)
      end
    end
    nil
  end

  def expired_jwt_for(email: nil, klass: 'User', login_field: :email, login_value: nil)
    value = login_value || email
    payload = { login: { login_field => value }, klass: klass, exp: Time.now.to_i - 3600 }
    JWT.encode(payload, Rubee::AuthTokenable::KEY, 'HS256')
  end
end
