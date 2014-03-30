module Medusa
  # When the process forks, the pipe is copied. When a pipe is
  # identified as a parent or child, it is choosing which ends
  # of the pipe to use.
  #
  # A pipe is actually two pipes:
  #
  #  Parent  == Pipe 1 ==> Child
  #  Parent <== Pipe 2 ==  Child
  #
  # It's like if you had two cardboard tubes and you were using
  # them to drop balls with messages in them between processes.
  # One tube is for sending from parent to child, and the other
  # tube is for sending from child to parent.
  class PipeTransport

    def self.pair
      child_read, parent_write = IO.pipe
      parent_read, child_write = IO.pipe
      
      return [PipeTransport.new(parent_read, parent_write), PipeTransport.new(child_read, child_write)]
    end

    def initialize(reader, writer)
      @reader, @writer = reader, writer
    end

    def read
      @reader.readline
    end

    def write(data)
      @writer.write("#{data}\n")
    end

    def close
      @reader.close
      @writer.close
    end

    def inspect
      "#<#{self.class} @reader=#{@reader.to_s}, @writer=#{@writer.to_s}>"
    end

  end
end