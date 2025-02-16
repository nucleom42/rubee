module Middlewarable
  def self.included(base)
    base.extend(ClassMethods)
    base.prepend(Initializer)
  end

  module Initializer
    def initialize(req, route)
      app = ->(env) { super(req, route) }
      self.class.middlewares.reverse_each do |middleware|
        middleware_class = Object.const_get(middleware)
        app = middleware_class.new(app, req)
      end
      app.call(req.env)
    end
  end

  module ClassMethods
    def attach(*args)
      @middlewares ||= []
      @middlewares.concat(args).uniq
    end

    def middlewares
      @middlewares || []
    end
  end
end
