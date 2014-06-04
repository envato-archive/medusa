module Medusa
  class Minion
    def initialize(message_handler)
      @logger = Medusa.logger.tagged(self.class.name)
      @message_handler = message_handler
    end

    def work!
      @logger.debug("Yes master! Working!")

      @message_handler.handle_message(Messages::RequestFile.new)
    end

    def handle_command(command)
      case command
      when Messages::RunFile then run_file(command)
      end
    end

    private

    def run_file(message)
      @logger.debug("Yes master! Running file #{message.file}")
      sleep(1)

      @message_handler.handle_message(Messages::TestResult.new(name: message.file))
    end
  end
end