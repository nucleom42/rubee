module Rubee
  class SidekiqAsync
    def perform_async(**args)
      options = if args[:options].is_a?(Hash)
        [JSON.generate(args[:options])]
      elsif args[:options].is_a?(Array)
        args[:options]
      else
        [args[:options]]
      end

      args[:_class].perform_async(*options)
    end
  end
end
