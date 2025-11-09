class WelcomeController < Rubee::BaseController
  attach_websocket! # Method required to turn controller to been able to handle websocket requests
  using ChargedHash

  def show
    response_with
  end

  def subscribe
    User.sub(@params[:channel], [@params[:options][:id], @params[:options][:io]]) do |channel, args|
      io = args[:io]
      Rubee::WebsocketConnections.instance.register(channel, io)
    end

    response_with(object: { channel: @params[:channel], status: :subscribed }, type: :websocket)
  rescue => e
    response_with(object: { error: e.message }, type: :websocket)
  end

  def unsubscribe
    User.unsub(@params[:channel], [@params[:options][:id], @params[:options][:io]]) do |channel, args|
      io = args[:io]
      Rubee::WebsocketConnections.instance.remove(channel, io)
    end

    response_with(object: @params, type: :websocket)
  rescue => e
    response_with(object: { error: e.message }, type: :websocket)
  end

  def publish
    args = {}
    User.pub(@params[:channel], message: @params[:message]) do |channel|
      args[:message] = @params[:message]
      args[:sender] = @params[:options][:id]
      Rubee::WebsocketConnections.instance.stream(channel, args)
    end

    response_with(object: { message: @params[:message], status: :published }, type: :websocket)
  rescue => e
    response_with(object: { error: e.message }, type: :websocket)
  end
end
