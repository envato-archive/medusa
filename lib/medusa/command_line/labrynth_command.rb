require 'escort'
require_relative '../labrynth'
require_relative '../dungeon'

module Medusa
  class CommandLine

    class LabrynthCommand < Escort::ActionCommand::Base
      def execute
        labrynth = Medusa::Labrynth.new(arguments.first)

        dungeons = (command_options[:dungeons] || 1).to_i

        1.upto(dungeons) { labrynth.dungeons << Medusa::Dungeon.new }

        labrynth.serve!
      end
    end
  end
end
