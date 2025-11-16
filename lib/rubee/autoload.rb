module Rubee
  class Autoload
    class << self
      def call(black_list = [], **options)
        load_whitelisted(options[:white_list_dirs]) && return if options[:white_list_dirs]
        # autoload all rbs
        root_directory = File.join(Rubee::ROOT_PATH, '/lib')
        priority_order_require(root_directory, black_list)
        # ensure sequel object is connected
        Rubee::SequelObject.reconnect!

        Dir.glob(File.join(Rubee::APP_ROOT, '**', '*.rb')).sort.each do |file|
          base_name = File.basename(file)

          unless base_name.end_with?('_test.rb') || (black_list + ['rubee.rb', 'test_helper.rb']).include?(base_name)
            require_relative file
          end
        end
      end

      def load_whitelisted(white_list_dirs)
        white_list_dirs.each do |dir|
          Dir[File.join(Rubee::ROOT_PATH, '/lib', "#{dir}/**", '*.rb')].each do |file|
            require_relative file
          end
        end
      end

      def priority_order_require(root_directory, black_list)
        # rubee inits
        Dir[File.join(root_directory, 'inits/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        # app inits
        Dir[File.join(Rubee::APP_ROOT, 'inits/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        # rubee pub sub
        Dir[File.join(root_directory, 'rubee/pubsub/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end if Rubee::Features.redis_available?
        # rubee websocket
        Dir[File.join(root_directory, 'rubee/websocket/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end if Rubee::Features.redis_available?
        # rubee async
        Dir[File.join(root_directory, 'rubee/async/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        # app config and routes
        unless black_list.include?('base_configuration.rb')
          require_relative File.join(Rubee::APP_ROOT, Rubee::LIB,
                                     'config/base_configuration')
        end
        # This is necessary prerequisitedb init step
        if Rubee::PROJECT_NAME == 'rubee'
          Rubee::Configuration.setup(env = :test) do |config|
            config.database_url = { url: 'sqlite://lib/tests/test.db', env: }
          end
        end

        require_relative File.join(Rubee::APP_ROOT, Rubee::LIB, 'config/routes') unless black_list.include?('routes.rb')
        # rubee extensions
        Dir[File.join(root_directory, 'rubee/extensions/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        # rubee controllers
        Dir[File.join(root_directory, 'rubee/controllers/middlewares/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        Dir[File.join(root_directory, 'rubee/controllers/extensions/**', '*.rb')].each do |file|
          require_relative file unless black_list.include?("#{file}.rb")
        end
        unless black_list.include?('base_controller.rb')
          require_relative File.join(root_directory,
                                     'rubee/controllers/base_controller')
        end
        # rubee models
        unless black_list.include?('database_objectable.rb')
          require_relative File.join(root_directory,
                                     'rubee/models/database_objectable')
        end
        return if black_list.include?('sequel_object.rb')

        require_relative File.join(root_directory,
                                   'rubee/models/sequel_object')
        return if black_list.include?('db_tools.rb')

        require_relative File.join(root_directory,
                                   'rubee/models/db_tools')

        Dir[File.join(root_directory, 'rubee/cli/**', '*.rb')].each do |file|
          require_relative file
        end
      end
    end
  end
end
