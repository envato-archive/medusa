module Medusa
  class TcpTransport
    attr_reader :host, :port

    def self.next_available_port
      @port ||= 19000
      @port += 1
      @port
    end

    def initialize(host, port = nil)
      @host = host
      @port = port || TcpTransport.next_available_port
    end

    def server!
      @server = TCPServer.new(@port)
      init_socket
    end

    # Blocks until a response.
    def read
      init_socket
      @socket.recv(10).to_s#[0..-2]  # Trim off the \n
    end

    # Writes data to the connection.
    def write(data)
      init_socket
      @socket.write("#{@data}")
    end

    def close
      @setup_complete = false
      @disconnected = true

      @socket.close if @socket
      @server.close if @server
    end

    def disconnected?
      @disconnected
    end

    private

    def init_socket
      return if @setup_complete

      if @server
        @socket = @server.accept
      else
        begin
          @socket = TCPSocket.new(@host, @port)
        rescue Errno::ECONNREFUSED
          puts "Waiting to connect to #{@host}:#{@port}"
          sleep(0.1)
          retry
        end
      end

      @setup_complete = true
    end

  end
end