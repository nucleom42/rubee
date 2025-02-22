class UsersController < BaseController
  include AuthTokenable
  auth_methods :index

  # GET
  def edit
    response_with
  end

  # POST
  def login
    if log_in!
      response_with object: { message: "Login successful", token: @token }, status: 200
    else
      response_with object: { error: "Invalid credentials" }, status: 401
    end
  end

  # GET (protected endpoint)
  def index
    response_with object: User.all, type: :json
  end
end
