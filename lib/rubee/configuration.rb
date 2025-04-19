module Rubee
  class Configuration
    include Singleton

    @configuraiton = {
      development: {
        database_url: '',
        port: 7000,
      },
      production: {},
      test: {},
    }

    class << self
      def setup(_env)
        yield(self)
      end

      def database_url=(args)
        @configuraiton[args[:env].to_sym][:database_url] = args[:url]
      end

      def async_adapter=(args)
        @configuraiton[args[:env].to_sym][:async_adapter] = args[:async_adapter]
      end

      def react=(args)
        @configuraiton[args[:env].to_sym][:react] ||= { on: false }
        @configuraiton[args[:env].to_sym][:react].merge!(on: args[:on])
      end

      def react
        @configuraiton[ENV['RACK_ENV']&.to_sym || :development][:react] || {}
      end

      def method_missing(method_name, *_args)
        return unless method_name.to_s.start_with?('get_')

        @configuraiton[ENV['RACK_ENV']&.to_sym || :development]&.[](method_name.to_s.delete_prefix('get_').to_sym)
      end

      def envs
        @configuraiton.keys
      end
    end
  end
end