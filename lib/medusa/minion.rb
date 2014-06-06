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

    def work!(file, report_back)
      raise ArgumentError, "Already working" if @current_work

      @logger.debug("Yessss master! Working on #{file}!")
      @logger.debug("Will report back to #{report_back}")

      if driver = Drivers::Acceptor.accept?(file)
        @current_work = Thread.new do
          begin
            driver.execute(file, report_back)
          rescue => ex
            report_back.inform_work_result(Messages::TestResult.fatal_error(file, ex))
          ensure
            @logger.debug("Reporting work complete")
            report_back.inform_work_complete(file.to_s, self)
            @current_work = nil
          end
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