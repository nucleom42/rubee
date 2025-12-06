require_relative '../test_helper'

class TestRedirectController < Rubee::BaseController
  def index
    response_with(type: :redirect, to: '/test')
  end

  def test
    response_with(type: :json, object: { ok: :ok })
  end
end

class BaseControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def setup
    Rubee::Router.draw do |route|
      route.get('/test', to: 'test_redirect#test')
      route.get('/index', to: 'test_redirect#index')
    end
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

  def test_redirect
    get('/index')

    assert_equal(302, last_response.status)
    assert_equal('/test', last_response.headers['Location'])
    assert_equal('', last_response.body)
  end
end
