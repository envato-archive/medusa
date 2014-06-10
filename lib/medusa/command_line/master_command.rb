require 'escort'
require_relative '../overlord'
require_relative '../drivers/acceptor'
require_relative '../reporters/log'

module Medusa
  class CommandLine

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

      def build_workers
        all_workers = Array(command_options[:workers]).collect do |worker|
          if worker == "local"
            { 'type' => 'local', 'runners' => command_options[:runners] }
          elsif worker =~ /(.*)\@(.*)\/(\d+)/
            { 'type' => 'ssh', 'connect' => "#{$1}@#{$2}", 'runners' => $3.to_i }
          elsif worker =~ /(.*)\/(\d+)/
            { 'type' => 'ssh', 'connect' => "#{$1}", 'runners' => $2.to_i }
          elsif worker =~ /(.*)\@(.*)/
            { 'type' => 'ssh', 'connect' => "#{$1}@#{$2}", 'runners' => command_options[:runners] }
          end
        end

        all_workers = [{ 'type' => 'local', 'runners' => command_options[:runners] }] if all_workers.empty?
        return all_workers
      end

      def execute
        begin
          # formatters = build_formatters
          # files = find_files_from_arguments
          # initializers = build_initializers
          # workers = build_workers
          # root = `pwd`.chomp

          $0 = "[medusa] Overlord running"

          Medusa.logger.level = case command_options[:verbosity]
          when "INFO" then ::Logger::INFO
          when "DEBUG" then ::Logger::DEBUG
          when "WARN" then ::Logger::WARN
          when "ERROR" then ::Logger::ERROR
          when "FATAL" then ::Logger::FATAL
          end

          Medusa.register_driver Medusa::Drivers::RspecDriver.new

          overlord = Medusa::Overlord.new
          overlord.keepers << Medusa::Keeper.new

          # Add any remote labyrinths if specified.
          command_options[:labyrinths].each do |addr|
            Medusa.dungeon_discovery.add_labyrinth addr
            overlord.keepers << Medusa::Keeper.new
          end

          pid = nil

          # If no labyrinths were specified, create a local one
          # for immediate execution.
          if command_options[:labyrinths].length == 0
            addr = "localhost:43553"
            pid = fork do
              l = Medusa::Labyrinth.new(addr)
              l.dungeons << Medusa::Dungeon.new(2)
              l.serve!
            end

            # Wait until the Labyrinth has started up.
            sleep(0.1) until Medusa::Labyrinth.available_at?(addr)

            Medusa.dungeon_discovery.add_labyrinth addr
          end

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

    end
  end
end
