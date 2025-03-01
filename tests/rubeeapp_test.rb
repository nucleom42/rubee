require_relative 'test_helper'

class RubeeAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def test_welcome_route
    get '/'

    assert last_response.ok?
    assert_equal last_response.body.include?('All set up and running!'), true
  end

  def test_not_found_route
    get '/random'

    assert_equal 404, last_response.status
  end
end
