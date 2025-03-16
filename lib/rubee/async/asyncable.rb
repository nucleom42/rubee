unless defined?(Rubee)
  require_relative '../../../../ee.rb'
  Rubee::Autoload.call
end

module Rubee
  module Asyncable
    def perform_async(args = {})
      args.merge!(_class: self.class)
      adapter.new.perform_async(**args)
    end

    def adapter
      @adapter ||= (Rubee::Configuration.get_async_adapter || ThreadAsync)
    end
  end
end
