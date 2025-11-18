require 'websocket'
require 'websocket/frame'
require 'websocket/handshake'
require 'websocket/handshake/server'
require 'json'
require 'redis'

module Rubee
  class WebSocket
    using ChargedHash
    class << self
      def call(env, &controller_block)
        unless env['rack.hijack']
          return [500, { 'Content-Type' => 'text/plain' }, ['Hijack not supported']]
        end

        env['rack.hijack'].call
        io = env['rack.hijack_io']

        handshake = ::WebSocket::Handshake::Server.new
        handshake.from_rack(env)
        unless handshake.valid?
          io.write("HTTP/1.1 400 Bad Request\r\n\r\n")
          io.close
          return [-1, {}, []]
        end

        io.write(handshake.to_s)
        incoming = ::WebSocket::Frame::Incoming::Server.new(version: handshake.version)

        outgoing = ->(data) do
          frame = ::WebSocket::Frame::Outgoing::Server.new(
            version: handshake.version,
            type: :text,
            data: data.to_json
          )
          io.write(frame.to_s)
        rescue IOError
          nil
        end

        # --- Listen to incoming data ---
        Thread.new do
          loop do
            data = io.readpartial(1024)
            incoming << data

            while (frame = incoming.next)
              case frame.type
              when :text
                out = controller_out(frame, outgoing, &controller_block)
                outgoing.call(**out)

              when :close
                # Client closed connection
                handle_close(frame, io, handshake)
                break
              end
            end
          end
        rescue EOFError, IOError
          begin
            handle_close(frame, io, handshake)
          rescue
            nil
          end
        end

        [101, handshake.headers, []]
      end

      def payload(frame)
        JSON.parse(frame.data)
      rescue
        {}
      end

      def handle_close(frame, io, handshake)
        payload_hash = payload(frame)
        channel = payload_hash["channel"]
        subcriber = payload_hash["subcriber"]
        ::Rubee::WebSocketConnections.instance.remove("#{channel}:#{subcriber}", io)
        io.write(::WebSocket::Frame::Outgoing::Server.new(
          version: handshake.version,
          type: :close
        ).to_s)
        io.close
      end

      def controller_out(frame, io, &block)
        payload_hash = payload(frame)
        action  = payload_hash["action"]
        channel = payload_hash["channel"]
        message = payload_hash["message"]
        options = payload_hash.select { |k, _| !["action", "channel", "message"].include?(k) }
        options.merge!(io:)

        block.call(channel:, message:, action:, options:)
      end
    end
  end
end
