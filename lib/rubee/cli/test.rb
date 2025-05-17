module Rubee
  module CLI
    module Test
      class << self
        def call(command, argv)
          send(command, argv)
        end

        def test(argv)
          ENV['RACK_ENV'] = 'test'
          file_name = argv[1] # Get the first argument
          lib = Rubee::PROJECT_NAME == 'rubee' ? '/lib' : ''
          if file_name
            color_puts("Running #{file_name} test ...", color: :yellow)
            exec("ruby -Itest -e \"require '.#{lib}/tests/#{file_name}'\"")
          else
            color_puts('Running all tests ...', color: :yellow)
            exec("ruby -Itest -e \"Dir.glob('.#{lib}/tests/**/*_test.rb').each { |file| require file }\"")
          end
        end
      end
    end
  end
end
