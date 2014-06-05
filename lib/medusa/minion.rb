require 'securerandom'
require_relative 'minion_trainer'

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
        driver.execute(file, self)
        @current_file = nil
      end
    end

  end
end