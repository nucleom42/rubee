class ApplesController < BaseController
  include Authable
  auth_methods :index

  before :index, :handle_unauthentificated, unless: :authenticated?
  before :index, :print_hello # you can useinstance method as a handler
  after :index, -> { puts "after index" }, if: -> { true } # or you can use lambda
  after :index, -> { puts "after index2" }, unless: -> { false } # if, unless guards may accept method or lambda
  around :index, :log

  def index
    response_with(**(@type_options || {}))
  end

  def print_hello
    puts "hello!"
  end

  def show
    # in memory example
    apples = [Apple.new(colour: 'red', weight: '1lb'), Apple.new(colour: 'green', weight: '1lb')]
    apple = apples.find { |apple| apple.colour = params[:colour] }

    response_with object: apple, type: :json
  end

  private

  def handle_unauthentificated
    # Ititiate type unauthorized, so it will be rendered properly in the
    # response_with method
    @type_options = { type: :unauthorized }
  end

  def log
    puts "before log aroud"
    res = yield
    puts "after log around"
    res # for the around this is important to return yiled result otherwise rack will raise an excpetion
  end
end
