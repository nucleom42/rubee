require_relative File.join(__dir__, 'helper')

class RubeeAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def setup
    Rubee::Autoload.call
  end

  def test_welcome_controller_included_auth_tokenable
    WelcomeController.include(AuthTokenable)
    WelcomeController.auth_methods :show

    get '/'

    assert_equal last_response.status, 401
  end
end
