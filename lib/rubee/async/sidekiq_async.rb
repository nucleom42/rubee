module Rubee
  class SidekiqAsync
    def perform_async(**args)
      options = serialize_options(args[:options])
      args[:_class].perform_async(*options)
    end

    def perform_at(interval, **args)
      options = serialize_options(args[:options])
      args[:_class].perform_at(interval, *options)
    end

    def perform_in(interval, **args)
      options = serialize_options(args[:options])
      args[:_class].perform_in(interval, *options)
    end

    def perform_later(interval, **args)
      perform_in(interval, **args)
    end

    def perform_bulk(jobs_args)
      jobs_args.map! do |args|
        options = serialize_options(args[:options])
        { args: options }
      end

      args[:_class].perform_bulk(jobs_args)
    end

    def set(options, **args)
      serialized_options = serialize_options(args[:options])
      args[:_class].set(options).perform_async(*serialized_options)
    end

    private

    def serialize_options(options)
      if options.is_a?(Hash)
        [JSON.generate(options)]
      elsif options.is_a?(Array)
        options
      else
        [options]
      end
    end
  end
end
