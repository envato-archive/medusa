require_relative 'logger'
require_relative 'keepers/local_client'
require_relative 'messages/request_file'
require_relative 'messages/test_result'
require_relative 'messages/run_file'

module Medusa

  # The Overlord is responsible for setting up keepers and their dungeons, 
  # and keeping track of what needs to be done, what has been done, and
  # distributing any results onto the relevant reporters.
  class Overlord
    attr_reader :keepers, :transport, :work, :work_in_progress, :work_complete

    def initialize
      @logger = Medusa.logger.tagged(self.class.name)

      @keepers = []
      @work = []
      @work_complete = []
      @work_in_progress = []
    end

    def prepare!
      @logger.debug("Preparing my underlings")

      @keepers.each do |keeper|
        keeper.prepare!(self)
      end

      @logger.debug("My underlings report they're ready for work")
    end

    def work!
      @logger.debug("Commanding underlings to work")

      @keepers.each do |keeper|
        keeper.work!
      end
    end

    def shutdown!
      @server.stop if @server
      @server = nil
    end

    def add_work(*files)
      @work.concat(files.flatten)
    end

    def handle_message(message, keeper)
      case message
      when Messages::RequestFile then send_work_to_keeper(keeper)
      when Messages::TestResult then record_work_result(message)
      end
    end

    private

    def send_work_to_keeper(keeper)
      @logger.debug("Sending work to the keeper")

      file = work.shift
      keeper.send_message(Messages::RunFile.new(file: file))
      work_in_progress << file
    end

    def record_work_result(result)
      @logger.debug("Received result for file #{result.name}")
      
      work_in_progress.delete(result.name)
      work_complete << result.name
    end

  end
end