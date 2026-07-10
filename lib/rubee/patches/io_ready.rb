require 'io/wait'

class IO
  unless method_defined?(:ready?)
    def ready?
      wait_readable(0)
    rescue IOError, Errno::EBADF
      false
    end
  end
end
