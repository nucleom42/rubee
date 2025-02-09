require 'rack'
require 'json'
require 'pry'

APP_ROOT = File.expand_path(File.dirname(__FILE__))
IMAGE_DIR = File.join(APP_ROOT, 'images')

module Rubee
  class Application
    def call(env)
      # autoload rb files
      Autoload.call
      # register images paths
      request = Rack::Request.new(env)
      # Add default path for images
      Router.draw { |route| route.get "/images/{path}", to: "base#image" }
      # define route
      route = Router.route_for(request)
      # init controller class
      raise "There is no path #{request.path} registered" unless route

      controller_class = "#{route[:controller].capitalize}Controller"
      # instantiate controller
      controller = Object.const_get(controller_class).new(request, route)
      # get the action
      action = route[:action]
      # fire the action
      controller.send(action)
    end

    def load_image(req)
      image_path = File.join(IMAGE_DIR, req.path.sub('/images/', ''))

      if File.exist?(image_path) && File.file?(image_path)
        mime_type = Rack::Mime.mime_type(File.extname(image_path))
        return [200, { "content-type" => mime_type }, [File.read(image_path)]]
      else
        return [404, { "content-type" => "text/plain" }, ["Image not found"]]
      end
    end
  end


  class Router
    HTTP_METHODS = [:get, :post, :put, :patch, :delete, :head, :connect, :options, :trace].freeze

    attr_reader :request

    @routes = []

    class << self
      def draw
        yield(self) if block_given?
      end

      def route_for(request)
        puts request.request_method
        @routes.find do |route|
          return route if request.path == route[:path] && request.request_method&.downcase&.to_sym == route[:method]

          pattern = route[:path].gsub(/{.*}/, '(.*)')
          regex = %r{^#{pattern}$}
          regex.match?(request.path) && request.request_method&.downcase&.to_sym == route[:method]
        end
      end

      def set_route(path, to:, method: __method__)
        controller, action = to.split("#")
        @routes << { path:, controller:, action:, method: }
      end

      HTTP_METHODS.each do |method|
        define_method method do |path, to:|
          set_route(path, to:, method: method)
        end
      end
    end
  end


  class Autoload
    class << self
      def call
        # autoload all rbs
        root_directory = File.dirname(__FILE__)
        Dir[File.join(root_directory, '**', '*.rb')].each do |file|
          require_relative file unless ['console.rb', 'rubee.rb'].include?(File.basename(file))
        end
      end
    end
  end
end

