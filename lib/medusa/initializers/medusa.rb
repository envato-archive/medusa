module Medusa
  module Initializers
    class Medusa < Abstract

      def run(command_stream)
        command_stream.write_raw("require 'rubygems'\n")
        command_stream.write_raw("require 'medusa'\n")

        command_stream.write_raw("Medusa::Worker.new(:io => Medusa::Stdio.new, :runners => #{worker[:runners] || 1}, :verbose => #{master.verbose}, :runner_log_file => \'#{master.runner_log_file}\')")
      end

    end
  end
end