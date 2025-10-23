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

        # --- Perform WebSocket handshake ---
        handshake = WebSocket::Handshake::Server.new
        handshake.from_rack(env)
        unless handshake.valid?
          io.write("HTTP/1.1 400 Bad Request\r\n\r\n")
          io.close
          return [-1, {}, []]
        end

        Rubee::Logger.debug(object: handshake)
        io.write(handshake.to_s)

        # --- WebSocket frames ---
        incoming = WebSocket::Frame::Incoming::Server.new(version: handshake.version)
        outgoing = ->(data) do
          frame = WebSocket::Frame::Outgoing::Server.new(
            version: handshake.version,
            type: :text,
            data: data
          )
          io.write(frame.to_s)
        end

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
                action = payload["action"]
                channel = payload["channel"]
                message = payload["message"]

                message = yield(payload)

                case action
                when "subscribe"
                  Thread.new do
                    redis_sub.subscribe(channel) do |on|
                      on.message do |ch, msg|
                        outgoing.call(JSON.dump({ channel: ch, message: msg }))
                      end
                    end
                  end
                  outgoing.call(JSON.dump({ system: "subscribed to #{channel}" }))
                when "publish"
                  redis_pub.publish(channel, message)
                else
                  outgoing.call(JSON.dump({ error: "unknown action" }))
                end

              when :close
                io.write(WebSocket::Frame::Outgoing::Server.new(
                  version: handshake.version,
                  type: :close
                ).to_s)
                io.close
                break
              end
            end
          rescue EOFError, IOError => e
            Rubee::Logger.error(message: e.message)
            io.close
            break
          end
        end

        [-1, {}, []]
      end

      def redis_pub
        @redis_pub ||= ConnectionPool::Wrapper.new { ::Redis.new }
      end

      def redis_sub
        @redis_sub ||= ConnectionPool::Wrapper.new { ::Redis.new }
      end
    end
  end
end
