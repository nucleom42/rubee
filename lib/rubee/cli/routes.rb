module Rubee
  module CLI
    class Routes
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def routes(_argv)
          file = Rubee::PROJECT_NAME == 'rubee' ? File.join(Dir.pwd, '/lib', 'config/routes.rb') : 'config/routes.rb'
          routes = eval(File.read(file)) # TODO: rewrite it omitting eval

          color_puts(routes, color: :green)
        end
      end
    end
  end
end
