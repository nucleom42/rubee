class FiberQueue
  def initialize
    @fibers = []
  end

  def add(task, args = {})
    fiber = Fiber.new do
      task.new.perform(**args)
    rescue => e
      puts "Fiber Error: #{e.message}"
    end
    @fibers << fiber
  end

  def fan_out!
    while @fibers.any?(&:alive?)
      @fibers.each do |fiber|
        fiber.resume if fiber.alive?
      end
    end
  end

  def done?
    @fibers.none?(&:alive?)
  end
end

