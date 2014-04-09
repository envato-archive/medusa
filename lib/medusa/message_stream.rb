module Medusa
  class MessageStream

    def initialize(transport)
      @transport = transport
    end

    def gets
      wait_for_message
    end

    def write(message)
      send_message(message)
    end

    def wait_for_message
      while true
        begin
          message = @transport.read
          puts "got #{message.inspect}"

          return Message.build(eval(message.chomp)) unless message.to_s == ""
        rescue SyntaxError, NameError => ex
          $stderr.write ex.class.name
          $stderr.write ex.message
          $stderr.write ex.backtrace
          # $stderr.write "Not a message: [#{message.inspect}] from #{@transport.inspect}\n"
        end
      end
    end

    # Write a Message to the output IO object. It will automatically
    # serialize a Message object.
    #  IO.write Medusa::Message.new
    def send_message(message)
      raise IOError unless @transport
      raise UnprocessableMessage unless message.is_a?(Message)

      puts "sending #{message.serialize}"

      @transport.write(message.serialize)
    end

    # Closes the IO object.
    def close
      @transport.close if @transport
    end

    # IO will return this error if it cannot process a message.
    # For example, if you tried to write a string, it would fail,
    # because the string is not a message.
    class UnprocessableMessage < RuntimeError
      # Custom error message
      attr_accessor :message
    end
  end
end