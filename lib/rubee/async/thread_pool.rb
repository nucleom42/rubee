require 'singleton'

module Rubee
  class ThreadPool
    include Singleton
    THREADS_LIMIT = 4 # adjust as needed

    def initialize
      @queue = Queue.new
      @workers = []
      @running = true
      @mutex = Mutex.new

      spawn_workers
    end

    def enqueue(task, args)
      @queue << { task: task, args: args }
    end

    def bulk_enqueue(tasks)
      @queue << tasks
    end

    def shutdown
      @running = false
      THREADS_LIMIT.times { @queue << { task: :stop, args: nil } }
      @workers.each(&:join)
    end

    private

    def spawn_workers
      THREADS_LIMIT.times do
        @workers << Thread.new do
          while @running
            task_hash = @mutex.synchronize { @queue.pop }
            if task_hash
              task = task_hash[:task]
              args = task_hash[:args]
            end
            break if task == :stop

            begin
              task.new.perform(**args)
            rescue StandardError => e
              puts "ThreadPool Error: #{e.message}"
            end
          end
        end
      end
    end
  end
end
