module Medusa
  module Initializers
    class Ruby

      attr_reader :medusa_boot

      def initialize
        @medusa_boot = "require 'rubygems'; require 'medusa'; "
        @medusa_boot += "Medusa::Worker.new(:io => Medusa::Stdio.new, :runners => #{runners}, :verbose => #{@verbose}, :runner_listeners => \'#{@string_runner_event_listeners}\', :runner_log_file => \'#{@runner_log_file}\' );"
      end

      def process_boot(command_stream)
        command_stream.write_raw("ruby -e \"#{medusa_boot}\"")
      end

    end
  end
end