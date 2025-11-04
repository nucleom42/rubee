class WelcomeController < Rubee::BaseController
  attach_websocket!
  using ChargedHash

  def show
    response_with
  end

  def subscribe
    response_with(object: @params, type: :websocket)
  end

  def unsubscribe
    response_with(object: @params, type: :websocket)
  end

  def publish
    rebuild_params!
    response_with(object: @params, type: :websocket)
  end

  private

  def rebuild_params!
    parsed_message = begin
                       JSON.parse(@params[:message])
                     rescue => _e
                       @params[:message]
                     end

    if parsed_message.is_a?(Hash)
      @params[:message] = parsed_message[:message]
      @params[:options].merge!({ sender: parsed_message[:options][:user] })
      @params[:options]&.delete(:user)
      @params[:options]&.delete("user")
    end
  end
end
