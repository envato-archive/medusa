require 'securerandom'
require 'drb'

require_relative 'minion_trainer'
require_relative 'drivers/acceptor'

module Medusa
  class Minion
    include DRbUndumped

    attr_reader :dungeon, :name

    def initialize(dungeon, name)
      @dungeon = dungeon
      @name = name.to_s

      @training_complete = false

      @logger = Medusa.logger.tagged("#{self.class.name} #{@dungeon.name} Minion ##{@name}")
    end

    def free?
      alive? && @training_complete && @current_file.nil?
    end

    def alive?
      !!@keeper
    end

    def receive_the_gift_of_life!(keeper, education_plan = nil)
      @logger = Medusa.logger.tagged("#{self.class.name} #{@dungeon.name} Minion ##{@name}")
      @logger.debug("I liiiive!")
      @keeper = keeper

      if education_plan
        MinionTrainer.train!(self, education_plan)
        @logger.debug("Education: Complete!")
      end

      @training_complete = true
    end

    def report_to(reporter)
      @logger.debug("I will report to #{reporter}!")
      @reporter = reporter
    end

    def train!(plan)
      @logger.debug("Training master!")
    end

    def work!(file)
      raise ArgumentError, "Already working" if @current_work

      @logger.debug("Yessss master! Working on #{file}!")
      @logger.debug("Will report back to #{@reporter}")

      if driver = Drivers::Acceptor.accept?(file)
        begin
          driver.execute(file, @reporter)
        rescue => ex
          @reporter.report(Messages::TestResult.fatal_error(file, ex))
        ensure
          @logger.debug("Reporting work complete")
          @current_file = nil
          @reporter.report(Messages::FileComplete.new(file))
        end
      end
    end

    def die!
      @logger.debug("I lived proudly to serve!")
      @keeper = nil
      @training_complete = false
      @logger = Medusa.logger.tagged("#{self.class.name} #{@dungeon.name} Minion ##{@name}")
    end

  end
end
