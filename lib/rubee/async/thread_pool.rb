require 'singleton'

module Rubee
  class ThreadPool
    include Singleton
    THREAD_POOL_LIMIT = Rubee::Configuration.get_thread_pool_limit || 10 # adjust as needed

    def initialize
      @queue = Queue.new
      @workers = []
      @running = true
      spawn_workers
    end

    def enqueue(task, args)
      @queue << { task: task, args: args }
      run_next
    end

    def bulk_enqueue(tasks)
      @queue << tasks
      run_next
    end

    def shutdown
      @running = false
      @queue.clear
    end

    private

    def run_next
      @workers.each do |fiber|
        fiber.resume if fiber.alive? && !@queue.empty?
      end
    end

    def spawn_workers
      THREAD_POOL_LIMIT.times do
        fiber = Fiber.new do
          loop do
            Fiber.yield unless @running
            job = @queue.shift
            break unless job

            task = job[:task]
            args = job[:args]

            begin
              task.new.perform(**args)
            rescue => e
              puts "ThreadPool Error: #{e.message}"
            end
          end
        end

        @workers << fiber
      end
    end
  end
end
