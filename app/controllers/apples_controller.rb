class ApplesController < BaseController
  def index
    @apples = Apple.all
    response_with
  end

  def new
    response_with
  end

  def edit
    @apple = Apple.find(params[:id])
    response_with
  end

  def show
    @apple = Apple.find(params[:id])
    response_with
  end

  def create
    @apple = Apple.new(params[:apple])
    if @apple.save
      response_with type: :redirect, to: "/apples/#{@apple.id}"
    else
      @errors = "Error occured while creating apple #{@apple.id}"
      response_with
    end
  end

  def update
    @apple = Apple.find(params[:id])
    if @apple.update(params[:apple])
      response_with type: :redirect, to: "/apples/#{@apple.id}"
    else
      @errors = "Error occured while updating apple #{@apple.id}"
      response_with
    end
  end

  def destroy
    @apple = Apple.find(params[:id])
    @apple.destroy
    response_with type: :redirect, to: "/apples"
  end
end
