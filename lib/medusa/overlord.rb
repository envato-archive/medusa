require 'benchmark'
require_relative 'logger'
require_relative 'keepers/local_client'
require_relative 'messages/request_file'
require_relative 'messages/test_result'
require_relative 'messages/run_file'
require_relative 'keeper_pool'
require_relative 'dungeon_plan'

module Medusa
  KEEPER_NAMES = [
    "Hades",
    "Persephone",
    "Kore",
    "Charon",
    "Hecate",
    "The Erinyes",
    "Hermes",
    "Minos",
    "Cerberus",
    "Thanatos",
    "Melinoe",
    "Akhlys",
    "Chairman Drek",
    "Doctor Nefarious",
    "Vox",
    "Emperor Otto Destruct",
    "Emperor Percival Tachyon",
    "Captain Slag",
    "Rusty Pete",
    "Captain Darkwater",
    "Flint Vorselon",
    "Artemis Zogg",
    "The Loki Master"
  ]

  # The Overlord is responsible for setting up keepers and their dungeons,
  # and keeping track of what needs to be done, what has been done, and
  # distributing any results onto the relevant reporters.
  class Overlord
    attr_reader :keepers, :reporters, :transport, :work, :work_in_progress, :work_complete, :plan

    def initialize
      @logger = Medusa.logger.tagged(self.class.name)

      @keepers = []
      @work = []
      @work_complete = []
      @work_in_progress = []
      @results = []
      @reporters = []
      @execution_times = []

      @plan = DungeonPlan.new
    end

    def prepare!
      b = Benchmark.measure do
        @logger.debug("Preparing my underlings")

        @pool = KeeperPool.new(KEEPER_NAMES)

        @keepers.each do |keeper|
          @pool.add_keeper(keeper)
        end

        @pool.prepare!(self)

        @logger.debug("My underlings report they're ready for work")
      end

      @execution_times << [:prepare!, b.real]
    end

    def work!
      @logger.debug("Giving work to my underlings")

      inform_reporters!(:report_all_work_begun, @work)

      @pool.accept_work!(@work)

      inform_reporters!(:report_all_work_completed)

      @results.freeze
      @results
    end

    def inform_work_result(result)
      @results << result
      inform_reporters!(:report_work_result, result)
    end

    def receive_report(message)
      @logger.debug("Received report #{message}")
      case message
      when String then inform_reporters!(:message, message)
      when Messages::TestResult then inform_reporters!(:report_work_result, message)
      when Messages::FileComplete then inform_reporters!(:report_work_complete, message)
      else
        @logger.debug("Unkonwn report type: #{message.class.name}")
      end
    rescue => ex
      @logger.error(ex.to_s)
    end

    def shutdown!
      @server.stop if @server
      @server = nil
    end

    def add_work(*files)
      @work.concat(files.flatten)
      @logger.debug("Added #{files.flatten.length} files to the workload")
    end

    def handle_message(message, keeper)
      case message
      when Messages::RequestFile then send_work_to_keeper(keeper)
      when Messages::TestResult then record_work_result(message)
      end
    end

    private

    def inform_reporters!(action, *arguments)
      @reporters.each do |reporter|
        @logger.debug("Informing reporter #{reporter} of #{action}")
        reporter.send(action.to_sym, *arguments) if reporter.respond_to?(action.to_sym)
      end
    end

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