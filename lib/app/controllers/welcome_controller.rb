class WelcomeController < Rubee::BaseController
  around :websocket, :handle_websocket

  def show
    response_with
  end

  def websocket
    incoming = @params['message']

    response_with(object: "Hello #{incoming}", type: :websocket)
  end

  def handle_websocket
    res = Rubee::Websocket.call(@request.env) do |payload|
      @params = payload
      yield
    end
    res
  end
end
