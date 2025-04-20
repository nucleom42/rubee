class FiberQueue
  def initialize
    @job_queue = []
  end

  def add(task, args = {})
    @job_queue << [task, args]
  end

  def fan_out!
    @job_queue.reject! do |task, args|
      fiber = Fiber.new do
        begin
          task.new.perform(**args)
        rescue => e
          puts "Fiber Error: #{e.message}"
        end
      end
      fiber.resume
      true # remove after running
    end
  end

  def done?
    @job_queue.empty?
  end
end

