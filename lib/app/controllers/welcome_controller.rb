class WelcomeController < Rubee::BaseController
  around :websocket, :handle_websocket

  def show
    response_with
  end

  def websocket
    incoming = @params[:frame_data]
    "Hello #{incoming}"
  end

  def handle_websocket
    res = Rubee::Websocket.call(@request.env) do |frame|
      @params = { frame_data: frame.data }
      yield
    end
    res
  end
end
