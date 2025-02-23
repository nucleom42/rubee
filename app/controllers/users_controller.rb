class UsersController < BaseController
  include AuthTokenable
  # List methods you want to authentificate
  auth_methods :index

  # GET
  def edit
    response_with
  end

  # POST
  def login
    if log_in!
      # Set jwt token to the browser within cookie, so next browser request will include it.
      token_header = { "set-cookie" => "jwt=#{@token}; path=/; httponly; secure" }

      response_with object: { message: "Login successful", token: @token },
        status: 200, type: :json, headers: token_header
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
