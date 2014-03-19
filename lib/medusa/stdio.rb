require 'medusa/messaging_io'
module Medusa #:nodoc:
  # Read and write via stdout and stdin.
  class Stdio
    include Medusa::MessagingIO

    # Initialize new Stdio
    def initialize()
      @reader = $stdin
      @writer = $stdout
      @reader.sync = true
      @writer.sync = true
    end
  end
end

