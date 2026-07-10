require_relative '../test_helper'

class AuthzController < Rubee::BaseController
  auth_methods(:admin_only, :user_only)
  authorize(admin: [:admin_only], model: :user, role_field: :role)

  # POST /authz/login
  def login
    if authentificate!
      response_with(type: :json, object: { ok: :ok }, headers: @token_header)
    else
      response_with(type: :json, object: { error: 'user unauthenticated' }, status: :unauthenticated)
    end
  end

  # GET /authz/admin_only
  def admin_only
    response_with(type: :json, object: { ok: :admin_access })
  end

  # GET /authz/user_only
  def user_only
    response_with(type: :json, object: { ok: :user_access })
  end
end

class AuthorizableTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def setup
    User.destroy_all
    Rubee::Autoload.call
    Rubee::Router.draw do |route|
      route.post('/authz/login', to: 'authz#login')
      route.get('/authz/admin_only', to: 'authz#admin_only')
      route.get('/authz/user_only', to: 'authz#user_only')
    end

    User.create(email: 'admin@example.com', password: '123456', role: 1)
    User.create(email: 'user@example.com', password: '123456', role: 0)
  end

  def login_as(email)
    post('/authz/login', { email:, password: '123456' })
    rack_mock_session.cookie_jar["jwt"] = last_response.cookies["jwt"].value.last
  end

  def test_admin_only_unauthenticated
    get('/authz/admin_only')

    assert_equal(403, last_response.status)
  end

  def test_admin_only_as_admin
    login_as('admin@example.com')

    get('/authz/admin_only')
    assert_equal(200, last_response.status)
  end

  def test_admin_only_as_user_forbidden
    login_as('user@example.com')

    get('/authz/admin_only')
    assert_equal(403, last_response.status)
  end

  def test_user_only_as_user
    login_as('user@example.com')

    get('/authz/user_only')
    assert_equal(200, last_response.status)
  end

  def test_user_only_as_admin_forbidden
    login_as('admin@example.com')

    get('/authz/user_only')
    assert_equal(200, last_response.status)
  end
end
