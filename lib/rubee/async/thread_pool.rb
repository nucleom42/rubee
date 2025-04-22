require 'singleton'

module Rubee
  class ThreadPool
    include Singleton
    THREADS_LIMIT = Rubee::Configuration.get_threads_limit || 4
    FIBERS_LIMIT = Rubee::Configuration.get_fibers_limit || 4

    def initialize
      @tasks = Queue.new
      @threads = []
      @running = true
      @mutex = Mutex.new

      spawn_workers
    end

    def enqueue(task, args = {})
      @tasks << [task, args]
    end

    def shutdown
      @running = false
      THREADS_LIMIT.times { @tasks << :shutdown } # Unblock threads
      @threads.each(&:join)
    end

    private

    def spawn_workers
      THREADS_LIMIT.times do
        @threads << Thread.new do
          while (task = @mutex.syncronize { @tasks.pop } && @running)
            break if task == :shutdown

            fiber_queue = FiberQueue.new
            fiber_queue.add(*task)

            # pull more to fill the chunk
            FIBERS_LIMIT.times do
              next_task = begin
                            @mutex.syncronize { @tasks.pop(true) }
                          rescue
                            nil
                          end
              fiber_queue.add(*next_task) if next_task
            end

            fiber_queue.fan_out! unless fiber_queue.done?
            sleep(0.1)
          end
        end
      end
    end
  end
end
