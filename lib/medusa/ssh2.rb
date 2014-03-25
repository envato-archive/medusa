require 'net/ssh'
require 'medusa/messaging_io'

module Medusa #:nodoc:
  # Read and write with an ssh connection. For example:
  #   @ssh = Medusa::SSH.new(
  #     'localhost', # connect to this machine
  #     '/home/user', # move to the home directory
  #     "ruby medusa/test/echo_the_dolphin.rb" # run the echo script
  #   )
  #   @message = Medusa::Messages::TestMessage.new("Hey there!")
  #   @ssh.write @message
  #   puts @ssh.gets.text
  #     => "Hey there!"
  #
  # Note that what ever process you run should respond with Medusa messages.
  class SSH2
    include Medusa::MessagingIO

    class ChannelWriter
      def initialize(channel)
        @channel = channel
      end

      def write(data)
        @channel.send_data(data)
      end
    end

    class ChannelReader
      def initialize(channel)
        @channel = channel

        @buffer = Queue.new

        @channel.on_data do |ch, data|
          puts data
          @buffer << data unless data.to_s == ""
        end
      end

      def gets
        # return nil if @buffer.empty?
        @buffer.pop
      end
    end



    # Initialize new SSH connection.
    # The first parameter is passed directly to ssh for starting a connection.
    # The second parameter is the directory to CD into once connected.
    # The third parameter is the command to run
    # So you can do:
    #   Medusa::SSH.new('-p 3022 user@server.com', '/home/user/Desktop', 'ls -l')
    # To connect to server.com as user on port 3022, then CD to their desktop, then
    # list all the files.
    def initialize(connection_options, directory)
      @connection = Net::SSH.start("localhost", "elseano")

      @connection.exec!("mkdir -p #{directory}")
      @directory = directory

      @connection.open_channel do |channel|
        @writer = ChannelWriter.new(channel)
        @reader = ChannelReader.new(channel)
      end
    end

    def execute_and_wait(command)
      @connection.exec!("cd #{@directory}; " + command)
    end

    def execute_as_channel(command)
      @connection.open_channel do |channel|
        channel.exec(command)
        @writer = ChannelWriter.new(channel)
        @reader = ChannelReader.new(channel)
      end
    end

    def write_raw(command)
      @writer.write(command)
    end

    def process!
      @connection.loop
    end

    # Close the SSH connection
    def close
      @connection.close
      super
    end
  end
end
