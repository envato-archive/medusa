require 'escort'

module Medusa
  class CommandLine

    # Handles invocation of a master from the command line.
    class MasterCommand < Escort::ActionCommand::Base

      def find_files_from_arguments
        files = []

        arguments.each do |path_spec|
          if File.file?(path_spec)
            files << path_spec
          else
            Dir.glob(File.join(path_spec, "**", "*")).each do |file|
              files << file if Drivers::Acceptor.accept?(file)
            end
          end
        end

        files
      end

      def build_formatters
        formatters = Array(command_options[:formatters])

        formatters.collect! do |f|
          case f
          when "progress" then Medusa::Listener::ProgressBar.new
          when /[a-zA-Z0-9\:]+/ then eval(f).new
          end
        end

        formatters.compact!
        formatters.uniq!

        if formatters.length == 0
          formatters = [Medusa::Listener::Log.new]
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
          formatters = build_formatters
          files = find_files_from_arguments
          initializers = build_initializers
          workers = build_workers
          root = `pwd`.chomp

          Medusa::Master.new(:files => files, :listeners => formatters.compact.uniq, :workers => workers, :verbose => true, :initializers => initializers, :root => root)
        rescue => ex
          puts ex.class.name
          puts ex.message
          puts ex.backtrace
        end
      end

    end
  end
end