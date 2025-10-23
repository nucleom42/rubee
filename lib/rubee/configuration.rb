module Rubee
  class Configuration
    include Singleton
    require_relative '../inits/charged_hash' unless defined?(ChargedHash)
    using ChargedHash

    @configuraiton = {
      app: {
        development: {
          database_url: '',
          port: 7000,
        },
        production: {},
        test: {},
      },
    }

    class << self
      def setup(env, app = :app)
        unless @configuraiton[app.to_sym]
          @configuraiton[app.to_sym] = {
            development: {},
            production: {},
            test: {},
          }
          unless @configuraiton[app.to_sym][env.to_sym]
            @configuraiton[app.to_sym][env.to_sym] = {}
          end
        end

        yield(self)
      end

      def database_url=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:database_url] = args[:url]
      end

      def async_adapter=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:async_adapter] = args[:async_adapter]
      end

      def threads_limit=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:thread_pool_limit] = args[:value]
      end

      def fibers_limit=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:fiber_pool_limit] = args[:value]
      end

      def db_max_retries=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:db_max_retries] = args[:value]
      end

      def db_retry_delay=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:db_retry_delay] = args[:value]
      end

      def db_busy_timeout=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:db_busy_timeout] = args[:value]
      end

      def logger=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:logger] = args[:logger]
      end

      def react=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:react] ||= { on: false }
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:react].merge!(on: args[:on])
      end

      def react(**args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][ENV['RACK_ENV']&.to_sym || :development][:react] || {}
      end

      def pubsub_container=(args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][args[:env].to_sym][:pubsub_container] = args[:pubsub_container]
      end

      def pubsub_container(**args)
        args[:app] ||= :app
        @configuraiton[args[:app].to_sym][ENV['RACK_ENV']&.to_sym || :development][:pubsub_container] || ::Rubee::PubSub::Redis.instance
      end

      def method_missing(method_name, *args)
        return unless method_name.to_s.start_with?('get_')

        app_name = args[0] || :app
        @configuraiton[app_name.to_sym][ENV['RACK_ENV']&.to_sym || :development]
          &.[](method_name.to_s.delete_prefix('get_').to_sym)
      end

      def envs
        @configuraiton.keys
      end
    end
  end
end
