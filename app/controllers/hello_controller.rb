class HelloController < ApplicationController
  def show
    if item = Item.find(params[:id])
      response_with object: item, type: :json
    else
      response_with object: { info: "Item with id:#{params[:id]} not found" }, status: 404, type: :json
    end
  end

  def index
    response_with object: Item.all, type: :json
  end

  def create
    if item = Item.create(**params)
      response_with object: item, type: :json, status: 201
    else
      response_with object: { info: "Item with params:#{params} was not created" }, status: 422, type: :json
    end
  end

  def update
    item = Item.find(params[:id])
    if item&.update(**params)
      response_with object: item, type: :json, status: 200
    else
      response_with object: { info: "Item with params:#{params} was not updated" }, status: 422, type: :json
    end
  end

  def delete
    if (item = Item.find(params[:id])) && item.destroy
      response_with object: item, type: :json
    else
      response_with object: { info: "Item with id:#{params[:id]} not found" }, status: 404, type: :json
    end
  end
end

