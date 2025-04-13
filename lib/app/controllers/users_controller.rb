class UsersController < Rubee::BaseController
  def index
    response_with object: User.all, type: :json
  end
end
