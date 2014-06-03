require 'escort'

module Medusa
  class CommandLine

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
            :runner_log_file => command_options[:runner_log_file],
            :worker_id => command_options[:worker_id]
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

