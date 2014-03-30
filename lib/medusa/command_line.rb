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

        begin
          Medusa::Master.new(:files => files, :listeners => formatters.compact.uniq, :workers => [
              {
                'type' => 'local', 
                'runners' => 1
              }
              # {
              #   'connect' => "sean@localhost",
              #   'type' => 'ssh', 
              #   'runners' => 1
              # }
            ],
            :verbose => true)
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
            puts "Connecting #{server}:#{ip}"
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

