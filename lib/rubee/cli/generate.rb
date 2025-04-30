module Rubee
  module CLI
    module Generate
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def generate(argv)
          method, path = argv[1..2]
          ENV['RACK_ENV'] ||= 'development'
          file = Rubee::PROJECT_NAME == 'rubee' ? File.join(Dir.pwd, '/lib', 'config/routes.rb') : 'config/routes.rb'
          routes = eval(File.read(file))
          route = routes.find { |route| route[:path] == path.to_s && route[:method] == method.to_sym }
          color_puts("Route not found with path: #{path} and method: #{method}", color: :red) unless route
          Rubee::Generator.new(
            route[:model]&.[](:name),
            route[:model]&.[](:attributes),
            "#{route[:controller]&.capitalize}Controller",
            route[:action],
            react: route[:react]
          ).call
        end

        alias_method :gen, :generate
      end
    end
  end
end
