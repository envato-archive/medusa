module Medusa
  module Drivers
    class RspecDriver < Abstract
      REDIRECTION_FILE = "/tmp/rspec-output.log"

      def detect(file)
        file =~ /_spec\.rb$/
      end

      def execute(file)
        conduit = Pipe.new

        pid = fork do
          conduit.identify_as_child

          require 'rspec'
          require 'medusa/spec/medusa_formatter'

          err = StringIO.new

          medusa_output = EventIO.new

          medusa_output.on_output do |message|
            conduit.write message
          end

          STDOUT.reopen(REDIRECTION_FILE)
          STDERR.reopen(REDIRECTION_FILE)

          RSpec::Core::Runner.run(["-fRSpec::Core::Formatters::MedusaFormatter", file.to_s], err, medusa_output)
        end

        conduit.identify_as_parent

        while Process.wait(pid, Process::WNOHANG).nil?
          message = conduit.gets
          message_bus.write message if message
        end

      ensure
        conduit.close
      end

      private

      def parse_options(options)
        if Array === options
          options = RSpec::Core::ConfigurationOptions.new(options)
          options.parse_options
        end

        options
      end

      def setup_environment(file, output)
        unless @core_config
          @core_config = RSpec::configuration.dup
        end

        @configuration = @core_config.dup

        @configuration.error_stream = output
        @configuration.output_stream = output

        @configuration.instance_variable_set("@formatters", nil)
        @configuration.instance_variable_set("@reporter", nil)
        @configuration.formatter = 'RSpec::Core::Formatters::MedusaFormatter'

        @configuration.files_to_run = [file.to_s]

        @world = RSpec.world = RSpec::Core::World.new(@configuration)

        @configuration.load_spec_files
        @world.announce_filters
      end
    end
  end
end
