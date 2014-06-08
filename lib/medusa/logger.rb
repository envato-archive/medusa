require 'logger'

module Medusa
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @logger = logger
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

    def info(message)
      @logger.info(message)
    end

    def error(message)
      @logger.error(message)
    end

    def fatal(message)
      @logger.fatal(message)
    end

    class TaggedLogger
      def initialize(base_logger, tag)
        @base_logger = base_logger
        @tag = tag
      end

      def debug(message)
        @base_logger.debug("[#{Thread.current.object_id}@#{@tag}] #{message}")
      end

      def info(message)
        @base_logger.info("[#{Thread.current.object_id}@#{@tag}] #{message}")
      end

      def error(message)
        @base_logger.error("[#{Thread.current.object_id}@#{@tag}] #{message}")
      end

      def fatal(message)
        @base_logger.fatal("[#{Thread.current.object_id}@#{@tag}] #{message}")
      end

    end
  end
end
