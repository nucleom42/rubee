class UsersController < Rubee::BaseController
  attach_websocket! # Method required to turn controller to been able to handle websocket requests
  using ChargedHash

  # Endpoint to find or create user
  def create
    user = User.where(**params).last
    user ||= User.create(**params)

    response_with(object: user, type: :json)
  rescue StandardError => e
    response_with(object: { error: e.message }, type: :json)
  end

  def subscribe
    channel = params[:channel]
    sender_id = params[:options][:id]
    io = params[:options][:io]

    User.sub(channel, sender_id, io) do |channel, args|
      websocket_connections.register(channel, args[:io])
    end

    response_with(object: { type: 'system', channel: params[:channel], status: :subscribed }, type: :websocket)
  rescue StandardError => e
    response_with(object: { type: 'system', error: e.message }, type: :websocket)
  end

  def unsubscribe
    channel = params[:channel]
    sender_id = params[:options][:id]
    io = params[:options][:io]

    User.unsub(channel, sender_id, io) do |channel, args|
      websocket_connections.remove(channel, args[:io])
    end

    response_with(object: params.merge(type: 'system', status: :unsubscribed), type: :websocket)
  rescue StandardError => e
    response_with(object: { type: 'system', error: e.message }, type: :websocket)
  end

  def publish
    args = {}
    User.pub(params[:channel], message: params[:message]) do |channel|
      user = User.find(params[:options][:id])
      args[:message] = params[:message]
      args[:sender] = params[:options][:id]
      args[:sender_name] = user.email
      websocket_connections.stream(channel, args)
    end

    response_with(object: { type: 'system', message: params[:message], status: :published }, type: :websocket)
  rescue StandardError => e
    response_with(object: { type: 'system', error: e.message }, type: :websocket)
  end
end
