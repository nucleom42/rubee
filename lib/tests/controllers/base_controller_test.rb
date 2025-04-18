require_relative '../test_helper'

class BaseControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def test_retrieve_image
    get('/images/rubee.svg')

    assert_equal(200, last_response.status, "Unexpected response: #{last_response.body}")
    refute_equal('Image not found', last_response.body, "Unexpected response: #{last_response.body}")
  end

  def test_retrieve_non_existant_image
    get('/images/rubee2.svg')

    assert_equal(200, last_response.status, "Unexpected response: #{last_response.body}")
    assert_equal('Image not found', last_response.body, "Unexpected response: #{last_response.body}")
  end
end
