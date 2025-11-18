require_relative '../test_helper'

class UsersControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rubee::Application.instance
  end

  def test_websocket_handshake_written_to_io
    env = Rack::MockRequest.env_for(
      '/ws',
      {
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO' => '/ws',
        'HTTP_CONNECTION' => 'keep-alive, Upgrade',
        'HTTP_UPGRADE' => 'websocket',
        'HTTP_HOST' => 'localhost:9292',
        'HTTP_ORIGIN' => 'http://localhost:9292',
        'HTTP_SEC_WEBSOCKET_KEY' => 'dGhlIHNhbXBsZSBub25jZQ==',
        'HTTP_SEC_WEBSOCKET_VERSION' => '13',
        'rack.url_scheme' => 'http'
      }
    )

    # Mock hijack interface expected by Rubee::WebSocket
    io = StringIO.new
    env['rack.hijack'] = proc {}
    env['rack.hijack_io'] = io

    # Call the WebSocket handler
    Rubee::WebSocket.call(env)

    # Expect the handshake response written to IO
    io.rewind
    handshake_response = io.read
    assert_includes(handshake_response, "HTTP/1.1 101 Switching Protocols")
    assert_includes(handshake_response, "Upgrade: websocket")
    assert_includes(handshake_response, "Connection: Upgrade")
  end
end
