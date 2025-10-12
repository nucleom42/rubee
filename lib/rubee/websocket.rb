require 'websocket'
require 'websocket/frame'
require 'websocket/handshake'
require 'websocket/handshake/server'

module Rubee
  class Websocket
    class << self
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

        io.write(handshake.to_s)

        # --- Create frame handler ---
        incoming = WebSocket::Frame::Incoming::Server.new(version: handshake.version)
        outgoing = ->(data) do
          frame = WebSocket::Frame::Outgoing::Server.new(
            version: handshake.version,
            type: :text,
            data: data
          )
          io.write(frame.to_s)
        end

        # --- Start message loop ---
        Thread.new do
          loop do
            data = io.readpartial(1024)
            incoming << data

            while frame = incoming.next
              case frame.type
              when :text
                outgoing.call("Echo: #{frame.data}")
              when :close
                io.write(WebSocket::Frame::Outgoing::Server.new(
                  version: handshake.version,
                  type: :close
                ).to_s)
                io.close
                break
              end
            end
          rescue EOFError, IOError
            io.close
            break
          end
        end

        [-1, {}, []]
      end
    end
  end
end
