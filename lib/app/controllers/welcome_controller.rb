class WelcomeController < Rubee::BaseController
  after :show, -> { puts 'after show' }
  def show
    response_with
  end
end
