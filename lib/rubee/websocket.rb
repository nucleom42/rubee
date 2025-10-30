require 'websocket'
require 'websocket/frame'
require 'websocket/handshake'
require 'websocket/handshake/server'
require 'json'
require 'redis'

module Rubee
  class Websocket
    class << self
      using ChargedHash

      def call(env)
        unless env['rack.hijack']
          return [500, { 'Content-Type' => 'text/plain' }, ['Hijack not supported']]
        end

        env['rack.hijack'].call
        io = env['rack.hijack_io']

        handshake = WebSocket::Handshake::Server.new
        handshake.from_rack(env)
        unless handshake.valid?
          io.write("HTTP/1.1 400 Bad Request\r\n\r\n")
          io.close
          return [-1, {}, []]
        end

        io.write(handshake.to_s)
        incoming = WebSocket::Frame::Incoming::Server.new(version: handshake.version)

        # Unique per connection
        connection_id = SecureRandom.uuid
        pubsub = Rubee::PubSub::RedisClassic.instance

        outgoing = ->(data) do
          frame = WebSocket::Frame::Outgoing::Server.new(
            version: handshake.version,
            type: :text,
            data: data.to_json
          )
          io.write(frame.to_s)
        rescue IOError
          # Socket closed
        end

        # --- Listen to incoming data ---
        Thread.new do
          begin
            loop do
              data = io.readpartial(1024)
              incoming << data

              while (frame = incoming.next)
                case frame.type
                when :text
                  payload = JSON.parse(frame.data) rescue {}
                  action  = payload["action"]
                  channel = payload["channel"]
                  message = payload["message"]

                  case action
                  when "subscribe"
                    result = pubsub.subscribe(connection_id, channel) do |ch, msg|
                      outgoing.call({ channel: ch, message: msg })
                    end
                    outgoing.call({ system: result[:status].to_s, channel: channel })

                  when "unsubscribe"
                    result = pubsub.unsubscribe(connection_id, channel)
                    outgoing.call({ system: result[:status].to_s, channel: channel })

                  when "publish"
                    pubsub.publish(channel, message)
                    outgoing.call({ system: "published", channel: channel })

                  else
                    outgoing.call({ error: "unknown action" })
                  end

                when :close
                  # Client closed connection
                  pubsub.unsubscribe_all(connection_id)
                  io.write(WebSocket::Frame::Outgoing::Server.new(
                    version: handshake.version,
                    type: :close
                  ).to_s)
                  io.close
                  break
                end
              end
            end
          rescue EOFError, IOError
            pubsub.unsubscribe_all(connection_id)
            io.close rescue nil
          end
        end

        [-1, {}, []]
      end
    end
  end
end
