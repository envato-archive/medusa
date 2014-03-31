require 'escort'

module Medusa
  class CommandLine

    class MasterCommand < Escort::ActionCommand::Base

      def find_files_from_arguments(arguments)
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
      
      def execute
        formatters = Array(command_options[:formatters])
        formatters.collect! do |f|
          case f
          when "progress" then Medusa::Listener::ProgressBar.new
          when /[a-zA-Z0-9\:]+/ then eval(f).new
          end
        end

        formatters = formatters.compact.uniq

        if formatters.length == 0
          formatters = [Medusa::Listener::ProgressBar.new]
        end

        files = find_files_from_arguments(arguments)

        initializers = []

        if File.exist?("vendor/cache")
          initializers << Medusa::Initializers::BundleLocal.new
        elsif File.exist?("Gemfile")
          initializers << Medusa::Initializers::BundleCache.new
        end

        if File.exist?("config/environment.rb")
          initializers << Medusa::Initializers::Rails.new
        end

        initializers << Medusa::Initializers::Medusa.new

        begin
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

          Medusa::Master.new(:files => files, :listeners => formatters.compact.uniq, :workers => all_workers, :verbose => true, :initializers => initializers)
        rescue => ex
          puts ex.class.name
          puts ex.message
          puts ex.backtrace
        end
      end

    end

    class WorkerCommand < Escort::ActionCommand::Base

      def execute
        begin
          transport = if command_options[:socket]
            Medusa::SocketTransport.new(command_options[:socket])
          elsif command_options[:tcp]
            server, ip = command_options[:tcp].split(":", 2)
            Medusa::TcpTransport.new(server, ip.to_i)
          end

          messages = Medusa::MessageStream.new(transport)

          Medusa::Worker.new(
            :io => messages, 
            :runners => command_options[:runners], 
            :verbose => true, 
            :runner_listeners => [], 
            :runner_log_file => command_options[:runner_log_file]
          )
        rescue => ex
          puts ex.class.name
          puts ex.message
          puts ex.backtrace
        end

      end

    end
  end
end

