require_relative './rubee'
class MyMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    puts "Before request"
    status, headers, body = @app.call(env)
    puts "After request"
    [status, headers, body]
  end
end
use MyMiddleware
run Rubee::Application.instance
