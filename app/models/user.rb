# User model is required for JWT authentification
# If you remove or modify it, make sure all changes are inlined
# with AuthTokenMiddleware and AuthTokenable modules
class User < SqliteObject
  attr_accessor :id, :email, :password
end
