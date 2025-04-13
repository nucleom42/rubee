class WelcomeController < Rubee::BaseController
  def show
    response_with
  end

  def not_found
    response_with type: :not_found
  end
end
