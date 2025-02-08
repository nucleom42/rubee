require 'rack'
require 'json'
require 'pry'

APP_ROOT = File.expand_path(File.dirname(__FILE__))

module Rubee
  class Application
    def call(env)
      # autoload rb files
      Autoload.call
      # init request
      request = Rack::Request.new(env)
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

