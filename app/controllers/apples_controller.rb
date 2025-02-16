class ApplesController < BaseController
  include Authable

  before :index, -> { puts "before index" }, if: -> { true }
  after :index, -> { puts "after index" }, if: -> { true }
  after :index, -> { puts "after index2" }, if: -> { true }
  around :index, :log, if: -> { true }

  def index
    if authenticated?
      response_with
    else
      response_with type: :unauthorized
    end
  end

  private

  def log
    puts "before log aroud"
    res = yield
    puts "after log around"
    res # for the around this is important to return yiled result otherwise rack will raise an excpetion
  end
end
