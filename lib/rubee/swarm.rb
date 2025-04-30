require 'socket'

module Rubee
  class Swarm
    def initialize(server = nil)
      @connections = {}
      @server = server
      @channels = {
        '/' => []
      }
    end

    def listen(port = 2345)
      puts "Starting Accepting websocket connection on port #{port}"

      @server ||= TCPServer.new(port)
      loop do
        # Wait for a connection
        Thread.new(@server.accept) do |socket|  
          next unless open(socket)
          
          loop do
            message = recieve(socket)

            headers = get_headers(socket)

            # Broadcast the message to all clients
            broadcast(message, socket, headers['Path'])
          end
        end
      end
    end
    
    def broadcast(message, socket, channel = '/')
      puts "Broadcasting to channel: #{channel} the message: #{message}"

      @clients.each do |client|
        next if client == socket

        output = [0b10000001, message.size, message]
        # client.send(message, Socket::MSG_OOB)
        client.write output.pack("CCA#{message.size}")
      end
    end

    def recieve(socket)
      data = socket.recv(1024)

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

      unmasked_data.pack('C*').force_encoding('utf-8').inspect
    end

    def open(socket)
      headers = get_headers(socket)

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
      @channels[headers['Path']] ||= []
      @channels[headers['Path']] << socket

      return true
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

      puts http_request

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
  end
end