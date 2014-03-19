require 'open3'
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
  class SSH
    include Open3
    include Medusa::MessagingIO

    # Initialize new SSH connection.
    # The first parameter is passed directly to ssh for starting a connection.
    # The second parameter is the directory to CD into once connected.
    # The third parameter is the command to run
    # So you can do:
    #   Medusa::SSH.new('-p 3022 user@server.com', '/home/user/Desktop', 'ls -l')
    # To connect to server.com as user on port 3022, then CD to their desktop, then
    # list all the files.
    def initialize(connection_options, directory, command)
      @writer, @reader, @error = popen3("ssh -tt #{connection_options}")
      @writer.write("mkdir -p #{directory}\n")
      @writer.write("cd #{directory}\n")
      @writer.write(command+"\n")
    end

    # Close the SSH connection
    def close
      @writer.write "exit\n"
      super
    end
  end
end
