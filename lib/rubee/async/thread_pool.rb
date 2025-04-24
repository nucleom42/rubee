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
          while @running && (task = @tasks.pop)
            break if task == :shutdown

            fiber_queue = FiberQueue.new
            fiber_queue.add(*task)

            # pull more to fill the chunk
            FIBERS_LIMIT.times do
              next_task = begin
                            @mutex.synchronize { @tasks.pop(true) }
                          rescue
                            nil
                          end
              fiber_queue.add(*next_task) if next_task
            end

            until fiber_queue.done?
              fiber_queue.fan_out!
            end

            sleep(0.05)
          end
        end
      end
    end
  end
end
