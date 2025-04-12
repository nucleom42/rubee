require_relative '../test_helper'

class AuthTokenableTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def setup
    Rubee::Autoload.call
  end

  def teardown
    # detach auth methods
    return unless WelcomeController.instance_variable_defined?(:@auth_methods)

    WelcomeController.send(:remove_instance_variable, :@auth_methods)
  end

  def test_welcome_controller_included_auth_tokenable
    WelcomeController.include(Rubee::AuthTokenable)
    WelcomeController.auth_methods(:show)

    get('/')

    assert_equal(last_response.status, 401)
  end
end
