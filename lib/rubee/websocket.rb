require 'websocket'
require 'websocket/frame'
require 'websocket/handshake'
require 'websocket/handshake/server'
require 'json'
require 'redis'

module Rubee
  class Websocket
    using ChargedHash
    class << self
      def call(env, &controller_block)
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
          loop do
            data = io.readpartial(1024)
            incoming << data

            while (frame = incoming.next)
              case frame.type
              when :text
                payload = begin
                            JSON.parse(frame.data)
                          rescue
                            {}
                          end
                payload_hash = payload
                action = payload_hash["action"]
                channel = payload_hash["channel"]
                message = payload_hash["message"]
                options = payload_hash.select { |k, _| !["action", "channel", "message"].include?(k) }
                case action
                when "subscribe"
                  result = pubsub.subscribe(connection_id, channel, payload) do |ch, msg, _opt|
                    # Publish handler
                    options = _opt.select { |k, _| !["action", "channel", "message"].include?(k) }
                    _controller_out = yield(channel: ch, message: msg, action: "publish", options:)
                    opt = _controller_out.select { |k, _| !["channel", "message"].include?(k) }
                    outgoing.call({ channel: ch, message: msg, **opt })
                  end
                  outgoing.call({ system: result[:status].to_s, channel: channel })

                when "unsubscribe"
                  result = pubsub.unsubscribe(connection_id, channel)
                  opt = controller_out(&controller_block).select { |k, _| !["channel", "message"].include?(k) }
                  outgoing.call({ system: result[:status].to_s, channel: channel, **opt })

                when "publish"
                  message = { message:, options: }
                  pubsub.publish(channel, message)
                  outgoing.call({ system: "published", **payload_hash })

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
          begin
            io.close
          rescue
            nil
          end
        end

        [-1, {}, []]
      end

      def payload
        JSON.parse(frame.data)
      rescue
        {}
      end

      def controller_out(&block)
        payload_hash = payload
        action  = payload_hash["action"]
        channel = payload_hash["channel"]
        message = payload_hash["message"]
        options = payload_hash.select { |k, _| !["action", "channel", "message"].include?(k) }

        block.call(channel:, message:, action:, options:)
      end
    end
  end
end
