require_relative '../test_helper'

class TestController < Rubee::BaseController
  include(Rubee::AuthTokenable)
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

class AuthTokenableTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def setup
    Rubee::Autoload.call
    Rubee::Router.draw do |route|
      route.post('/test/login', to: 'test#login')
      route.post('/test/logout', to: 'test#logout')
      route.get('/test/show', to: 'test#show')
    end
    User.create(email: '9oU8S@example.com', password: '123456')

  end

  def test_test_controller_included_auth_tokenable
    get('/test/show')

    assert_equal(last_response.status, 401)
  end

  def test_test_controller_included_auth_tokenable_authenticated
    post('/test/login', { email: '9oU8S@example.com', password: '123456' })
    rack_mock_session.cookie_jar["jwt"] = last_response.cookies["jwt"].value.last
    get('/test/show')

    assert_equal(last_response.status, 200)
  end

  def test_test_controller_included_auth_tokenable_authenticated_custom_model

  end
end
