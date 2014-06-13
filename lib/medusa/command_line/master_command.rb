require 'escort'
require_relative '../overlord'
require_relative '../drivers/acceptor'
require_relative '../reporters/log'

module Medusa
  class CommandLine

    VERBOSITY_LEVELS = {
      "DEBUG" => ::Logger::DEBUG,
      "INFO" => ::Logger::INFO,
      "WARN" => ::Logger::WARN,
      "ERROR" => ::Logger::ERROR,
      "FATAL" => ::Logger::FATAL
    }

    # Handles invocation of a master from the command line.
    class MasterCommand < Escort::ActionCommand::Base

      def add_work_from_arguments(overlord)
        arguments.each do |path_spec|
          if File.file?(path_spec)
            overlord.add_work path_spec
          else
            Dir.glob(File.join(path_spec, "**", "*")).each do |file|
              overlord.add_work file if Drivers::Acceptor.accept?(file)
            end
          end
        end
      end

      def build_formatters
        formatters = Array(command_options[:formatters])

        formatters.collect! do |f|
          case f
          when "progress" then Medusa::Reporters::ProgressBar.new
          when /[a-zA-Z0-9\:]+/ then eval(f).new
          end
        end

        formatters.compact!
        formatters.uniq!

        if formatters.length == 0
          formatters = [Medusa::Reporters::Log.new]
        end

        formatters
      end

      def build_initializers
        initializers = [Medusa::Initializers::RSync.new]

        if File.exist?("vendor/cache")
          initializers << Medusa::Initializers::BundleLocal.new
        elsif File.exist?("Gemfile")
          initializers << Medusa::Initializers::BundleCache.new
        end

        if File.exist?("config/environment.rb")
          initializers << Medusa::Initializers::Rails.new
        end

        initializers << Medusa::Initializers::Medusa.new
      end

      def execute
        begin
          # TODO - Restore formatter and initializer construction.
          # formatters = build_formatters
          # initializers = build_initializers

          $0 = "[medusa] Overlord running"

          Medusa.logger.level = VERBOSITY_LEVELS[command_options[:verbosity]]
          Medusa.register_driver Medusa::Drivers::RspecDriver.new

          overlord = Medusa::Overlord.new

          # Add any remote labyrinths if specified.
          command_options[:labyrinths].each do |addr|
            Medusa.dungeon_discovery.add_labyrinth addr
            overlord.keepers << Medusa::Keeper.new
          end

          pid = nil

          # If no labyrinths were specified, create a local one
          # for immediate execution.
          # setup_local_labyrinth unless Medusa.dungeon_discovery.labyrinths_available?

          add_work_from_arguments(overlord)

          overlord.reporters << Medusa::Reporters::RSpecStyle.new

          overlord.prepare!
          overlord.work!
        rescue => ex
          puts ex.class.name
          puts ex.message
          puts ex.backtrace
        ensure
          if pid
            Process.kill("KILL", pid)
          end
        end
      end

      private


      def setup_local_labyrinth
        addr = "localhost:43553"
        pid = fork do
          begin
            ParentTerminationWatcher.termination_thread!

            l = Medusa::Labyrinth.new(addr)
            l.dungeons << Medusa::Dungeon.new(2)
            l.serve!
          rescue ParentTerminationWatcher::Terminated
          end
        end

        Medusa.dungeon_discovery.add_labyrinth addr

        # Wait until the Labyrinth has started up.
        sleep(0.1) until Medusa::Labyrinth.available_at?(addr)
      end

    end
  end
end
