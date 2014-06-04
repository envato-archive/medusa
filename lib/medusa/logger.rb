require 'logger'

module Medusa
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  class Logger
    def initialize(output)
      @output = output
      @logger = ::Logger.new(@output)
    end

    def tagged(tag)
      TaggedLogger.new(self, tag)
    end

    def debug(message)
      @logger.debug(message)
    end

    class TaggedLogger
      def initialize(base_logger, tag)
        @base_logger = base_logger
        @tag = tag
      end

      def debug(message)
        @base_logger.debug("[#{@tag}] #{message}")
      end
    end
  end
end