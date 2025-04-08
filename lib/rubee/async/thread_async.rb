module Rubee
  class ThreadAsync
    def perform_async(**args)
      color_puts 'WARN: ThreadAsync engine is not yet recommended for production', color: :yellow
      ThreadPool.instance.enqueue(args[:_class], args[:options])
    end
  end
end
