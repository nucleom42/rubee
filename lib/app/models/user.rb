# WARNING: User model is required for JWT authentification
# If you remove or modify it, make sure all changes are inlined
# with AuthTokenMiddleware and AuthTokenable modules
class User < Rubee::SequelObject
  include Rubee::PubSub::Subscriber
  include Rubee::PubSub::Publisher

  attr_accessor :id, :email, :password, :created, :updated

  class << self
    def on_pub(channel, message, options = {})
      { channel:, message:, options: options.except(:io) }
    end
  end
end
