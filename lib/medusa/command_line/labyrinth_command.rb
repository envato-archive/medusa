require 'escort'
require_relative '../labyrinth'
require_relative '../labyrinth_announcer'
require_relative '../dungeon'

module Medusa
  class CommandLine

    class LabyrinthCommand < Escort::ActionCommand::Base
      def execute

        bind_address = arguments.first || "localhost:9000"

        labyrinth = Medusa::Labyrinth.new(bind_address)

        dungeons = (command_options[:dungeons] || 1).to_i

        1.upto(dungeons) { labyrinth.dungeons << Medusa::Dungeon.new }

        announce(bind_address)

        labyrinth.serve!
      end

      def announce(bind_address)
        if announce_ether?
          LabyrinthAnnouncer.announce(port(bind_address))
        end
      end

      def announce_ether?
        announce? && command_options[:announce] == "ether"
      end

      def announce?
        command_options[:announce]
      end

      def port(bind_address)
        bind_address.split(":")[1].to_i
      end

    end
  end
end
