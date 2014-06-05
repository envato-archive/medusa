require 'securerandom'

require_relative 'minion_trainer'
require_relative 'drivers/acceptor'

module Medusa
  class Minion
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

    def work!(file)
      @current_file = file
      @logger.debug("Yessss master! Working!")

      if driver = Drivers::Acceptor.accept?(file)
        Thread.new do
          begin
            driver.execute(file, self)
          rescue => ex
            @keeper.fatal_error(file, ex, minion)
          ensure
            @current_file = nil
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

    def receive_result(file, result)
      @logger.debug("Got result on #{file}")
      @keeper.receive_result(file, result, self)
      @logger.debug("REPORTED #{file}")
    rescue => ex
      @logger.debug("ERROR: #{ex.to_s}")
    end

  end
end