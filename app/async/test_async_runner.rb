class TestAsyncRunnner
  include Asyncable

  def run(args)
    sleep(1)
    puts "I'm async runner #{args[:id]}"
  end
end
