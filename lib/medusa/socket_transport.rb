require 'socket'

module Medusa
  class SocketTransport
    def initialize(path)
      @path = path
    end

    # Blocks until data is returned.
    def read
      init_socket
      @socket.recv(100_000)
    end

    # Blocks until a client is connected.
    def write(data)
      init_socket
      @socket.send data, 0
    end

    def close
      @socket.close if @socket
      @server.close if @server
    end

    private

    def init_socket
      if @socket.nil?
        begin
          if File.exist?(@path) && File.socket?(@path)
            @socket = UNIXSocket.new(@path)
          else
            @server = UNIXServer.new(@path)
            @socket = @server.accept
          end
        rescue Errno::ECONNREFUSED
          File.unlink(@path) if File.exist?(@path) && File.socket?(@path)
          puts "RETRY"
          retry
        end
      end
    end
  end
end