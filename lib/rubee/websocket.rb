require 'socket'

module Rubee
  class Websocket
    def initialize(server = nil)
      @connections = {}
      @server = server
      @clients = []
    end

    def listen(port = 2345)
      puts "Starting Accepting websocket connection on port #{port}"

      @server ||= TCPServer.new(port)
      loop do
        # Wait for a connection
        Thread.new(@server.accept) do |socket|  
          headers = get_headers(socket)
          
          next unless open(socket, headers)
          
          loop do
            message = recieve(socket)
            broadcast(message, socket) unless message.nil? || message.empty?

          rescue IOError => e
            close(socket)
            puts "Error receiving message: #{e.message}"
            break
          end
        end
      end
    end
    
    def broadcast(message, socket)
      # puts "Broadcasting the message: #{message}"

      @clients.each do |client|
        next if client == socket

        begin
          frame = construct_frame(message)
          client.write frame
        rescue
          @clients.delete client
        end
      end
    end

    def recieve(socket)
      data = socket.recv(1024)

      if data.nil? || data.empty?
        return ''
      end

      unpackedData = data.unpack('C*')

      length = unpackedData[1] & 127

      if length == 127
        length = unpackedData[2..9].pack('C*').unpack('Q>').first
      elsif length == 126
        length = unpackedData[2..3].pack('C*').unpack('n').first
      end

      mask = unpackedData[2..5]

      unmasked_data = unpackedData[6..-1].each_with_index.map do |byte, i|
        byte ^ mask[i % 4]
      end

      message = unmasked_data.pack('C*').force_encoding('utf-8')

      # Check if the message is a close frame
      if unpackedData[0] == 0b10000001 && length == 0
        # Send a close frame back to the client
        close_frame = [0b10000001, 0].pack('CC')
        socket.write close_frame
        close(socket)
        return ''
      end

      # Check if message is a close frame
      if message == "\u0003\xE9"
        close(socket)
        return ''
      end

      message
    end

    def open(socket, headers)

      return false unless headers["Sec-WebSocket-Key"]

      # Generate the accept key
      accept_key = headers["Sec-WebSocket-Key"] + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
      sha1 = Digest::SHA1.digest(accept_key)
      accept_key = Base64.encode64(sha1).strip

      # Send the response
      socket.print "HTTP/1.1 101 Switching Protocols\r\n" +
                  "Upgrade: websocket\r\n" +
                  "Connection: Upgrade\r\n" +
                  "Sec-WebSocket-Accept: #{accept_key}\r\n\r\n"

      # Add the socket to the list of clients
      # @channels[headers['Path']] ||= []
      # @channels[headers['Path']] << socket
      @clients << socket
      puts "Client connected: #{socket}"

      return true
    end

    def close(socket)
      puts "Client disconnected: #{socket}"
      # Remove the socket from the list of clients
      @clients.delete(socket)

      # Send a close frame to the client
      close_frame = [0b10000001, 0].pack('CC')
      socket.write close_frame

      # Close the socket
      socket.close
    end

    def register(room)
      # Create a new channel if it doesn't exist
      @channels[room] ||= { clients: [], messages: [] }
    end
    
    private

    def get_headers(socket)
      # Read the HTTP request. We know it's finished when we see a line with nothing but \r\n
      http_request = ""
      while (line = socket.gets) && (line != "\r\n")
        http_request += line
      end

      # Parse the request
      headers = {}

      # puts http_request

      split_request = http_request.split("\r\n")

      split_request.each do |line|
        if line =~ /^(.*?): (.*)$/
          headers[$1] = $2
        end
      end

      header_action = split_request[0].split(" ")

      headers['Action'] = header_action[0]
      headers['Path'] = header_action[1]
      headers['Version'] = header_action[2]

      headers
    end

    def construct_frame(message)
      byte1 = 0b10000001 # FIN bit set, text frame
      length = message.bytesize

      if length <= 125
        [byte1, length, message].pack("CCA#{length}")
      elsif length <= 65535
        [byte1, 126, [length].pack('n'), message].pack("CCa*")
      else
        [byte1, 127, [length].pack('Q>'), message].pack("CCa*")
      end
    end
  end
end
