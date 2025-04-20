require 'singleton'

module Rubee
  class ThreadPool
    include Singleton
    THREAD_POOL_LIMIT = Rubee::Configuration.get_thread_pool_limit || 10

    def initialize
      @queue = []
      @workers = []
      @running = true
      spawn_workers
    end

    def enqueue(task, args)
      @queue << { task: task, args: args }
    end

    def bulk_enqueue(tasks)
      @queue.concat(tasks)
    end

    def tick
      # Run each fiber once if it's alive
      @workers.each do |fiber|
        fiber.resume if fiber.alive? && @queue.any?
      end
    end

    def shutdown
      @running = false
      @queue.clear
    end

    private

    def spawn_workers
      THREAD_POOL_LIMIT.times do
        fiber = Fiber.new do
          loop do
            Fiber.yield
            break unless @running

            job = @queue.shift
            next unless job

            begin
              job[:task].new.perform(**job[:args])
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

