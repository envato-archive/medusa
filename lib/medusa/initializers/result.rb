module Medusa
  module Initializers

    class Result
      attr_accessor :exit_status
      attr_reader :command

      def initialize(command)
        @command = command
        @output = []      
      end

      def <<(line)
        @output << line
      end

      def output
        @output.join("\n")
      end

      def ok?
        exit_status == 0
      end
    end
  end
end