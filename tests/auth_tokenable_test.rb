require "minitest/autorun"
require "rack/test"
require_relative File.join(__dir__, '..', 'rubee')

class RubeeAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def setup
    Rubee::Autoload.call
    WelcomeController.include(AuthTokenable)
    WelcomeController.auth_methods :show
  end

  def test_welcome_controller_included_auth_tokenable
    get "/"

    assert_equal last_response.status, 401
  end
end

