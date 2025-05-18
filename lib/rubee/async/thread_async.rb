module Rubee
  class ThreadAsync
    def perform_async(**args)
      color_puts('WARN: ThreadAsync engine is experimental!', color: :yellow)
      ThreadPool.instance.enqueue(args[:_class], args[:options])
    end
  end
end
