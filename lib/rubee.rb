require 'singleton'
require 'bundler/setup'
require 'bundler'

begin
  Bundler.require(:default)
rescue StandardError
  nil
end

module Rubee
  APP_ROOT = File.expand_path(Dir.pwd) unless defined?(APP_ROOT)
  PROJECT_NAME = File.basename(APP_ROOT) unless defined?(PROJECT_NAME)
  LIB = PROJECT_NAME == 'rubee' ? 'lib/' : '' unless defined?(LIB)
  IMAGE_DIR = File.join(APP_ROOT, LIB, 'images') unless defined?(IMAGE_DIR)
  JS_DIR = File.join(APP_ROOT, LIB, 'js') unless defined?(JS_DIR)
  CSS_DIR = File.join(APP_ROOT, LIB, 'css') unless defined?(CSS_DIR)
  ROOT_PATH = File.expand_path(File.join(__dir__, '..')) unless defined?(ROOT_PATH)
  unless defined?(RUBEE_SUPPORT)
    RUBEE_SUPPORT = { "Rubee::Support::Hash" => Hash, "Rubee::Support::String" => String }
  end

  VERSION = '2.6.0'

  require_relative 'rubee/router'
  require_relative 'rubee/logger'
  require_relative 'rubee/generator'
  require_relative 'rubee/features'
  require_relative 'rubee/autoload'
  require_relative 'rubee/configuration'

  class Application
    include Singleton
    using(ChargedString)

    def call(env)
      # autoload rb files
      Autoload.call
      # init rack request
      request = Rack::Request.new(env)
      # Add default path for assets
      register_assets_routes
      # define route
      route = Router.route_for(request)
      # if react is the view so we would like to delegate not cauth by rubee routes to it.
      if Rubee::Configuration.react[:on] && !route
        index = File.read(File.join(Rubee::APP_ROOT, Rubee::LIB, 'app/views', 'index.html'))
        return [200, { 'content-type' => 'text/html' }, [index]]
      end
      # if not found return 404
      return [404, { 'content-type' => 'text/plain' }, ['Route not found']] unless route
      # init controller class
      controller_class = if route[:namespace]
        "#{route[:namespace].to_s.camelize}::#{route[:controller].camelize}Controller"
      else
        "#{route[:controller].camelize}Controller"
      end
      # instantiate controller
      controller = Object.const_get(controller_class).new(request, route)
      # get the action
      action = route[:action]
      # fire the action
      controller.send(action)
    end

    private

    def register_assets_routes
      Router.draw do |route|
        route.get('/images/{path}', to: 'base#image', namespace: 'Rubee')
        route.get('/js/{path}', to: 'base#js', namespace: 'Rubee')
        route.get('/css/{path}', to: 'base#css', namespace: 'Rubee')
      end
    end
  end
end
