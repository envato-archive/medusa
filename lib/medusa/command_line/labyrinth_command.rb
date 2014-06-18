require 'escort'
require_relative '../labyrinth'
require_relative '../dungeon'

module Medusa
  class CommandLine

    class LabyrinthCommand < Escort::ActionCommand::Base
      def execute 
        Medusa.register_driver Medusa::Drivers::RspecDriver.new
        
        labyrinth = Medusa::Labyrinth.new(arguments.first || "localhost:9000")

        dungeons = (command_options[:dungeons] || 1).to_i

        1.upto(dungeons) { labyrinth.dungeons << Medusa::Dungeon.new }

        labyrinth.serve!
      end
    end
  end
end
