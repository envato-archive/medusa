module Medusa #:nodoc:
  # Module that implemets methods that auto-serialize and deserialize messaging
  # objects.
  module MessagingIO
    # Read a Message from the input IO object. Automatically build
    # a message from the response and return it.
    #
    #  IO.gets
    #    => Medusa::Message # or subclass
    def gets
      while true
        begin
          raise IOError unless @reader
          message = @reader.gets
          return nil if message.to_s.chomp == ""
          return Message.build(eval(message.chomp))
        rescue SyntaxError, NameError
          # uncomment to help catch remote errors by seeing all traffic
          $stderr.write "Not a message: [#{message.inspect}]\n"
        end
      end
    end

    # Write a Message to the output IO object. It will automatically
    # serialize a Message object.
    #  IO.write Medusa::Message.new
    def write(message)
      raise IOError unless @writer
      raise UnprocessableMessage unless message.is_a?(Medusa::Message)

      # Note - Sometimes output from shell commands get mixed with messages,
      # so we wrap messages with newlines to try to avoid this.
      @writer.write("\n"+message.serialize+"\n")
    rescue Errno::EPIPE
      raise IOError
    end

    # Closes the IO object.
    def close
      @reader.close if @reader
      @writer.close if @writer
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