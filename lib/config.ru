require_relative './rubee'

rubee_app = Rubee::Application.instance
puts "middlewares: #{rubee_app.middlewares}"
rubee_app.middlewares.each do |middleware|
  use middleware
end
run rubee_app
