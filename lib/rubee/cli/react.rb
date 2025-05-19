module Rubee
  module CLI
    class React
      class << self
        def call(command, argv)
          command = argv[1]
          send(command, argv)
        end

        def prepare(_argv)
          if Rubee::PROJECT_NAME == 'rubee'
            exec('cd ./lib && npm run prepare')
          else
            exec('npm run prepare')
          end
        end

        def watch(_argv)
          if Rubee::PROJECT_NAME == 'rubee'
            exec('cd ./lib && npm run watch')
          else
            exec('npm run watch')
          end
        end
      end
    end
  end
end
