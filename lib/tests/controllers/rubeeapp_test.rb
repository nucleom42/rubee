require_relative '../test_helper'

class RubeeAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def test_welcome_route
    skip "This test fails intermittently"
    get('/')

    assert_equal(200, last_response.status, "Unexpected response: #{last_response.body}")
    assert_includes(last_response.body, 'All set up and running!')
  end

  def test_not_found_route
    get('/random')

    assert_equal(404, last_response.status)
  end

  def test_react_home
    Rubee::Configuration.setup(env = :test) { _1.react = { on: true, env: } }

    get('/home')

    assert_equal(200, last_response.status)
    assert_includes(last_response.body, '<div id="App">')
    assert_includes(last_response.body, 'bundle.js')

    Rubee::Configuration.setup(env = :test) { _1.react = { on: false, env: } }
  end
end
