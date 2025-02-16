require_relative File.join(__dir__, 'middlewarable')

module Authable
  def self.included(base)
    base.include(Middlewarable)
    base.include(InstanceMethods)
    base.extend(ClassMethods)

    base.attach('AuthTokenMiddleware')
  end

  module InstanceMethods
    def authenticated?
      @request.env["rack.session"]&.[]("authenticated")
    end
  end

  module ClassMethods

  end
end
