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
      response_with object: { message: "Login successful", token: @token }, status: 200, type: :json
    else
      @error = "Wrong email or password"
      response_with render_view: "users_edit"
    end
  end

  # GET (protected endpoint)
  def index
    response_with object: User.all, type: :json
  end
end
