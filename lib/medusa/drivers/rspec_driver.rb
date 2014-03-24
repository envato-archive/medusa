module Medusa
  module Drivers
    class RspecDriver < Abstract

      def detect(file)
        file =~ /_spec\.rb$/
      end

      def execute(file)
        begin
          require 'rspec'
          require 'medusa/spec/medusa_formatter'
        rescue LoadError => ex
          return ex.to_s
        end

        medusa_output = EventIO.new

        medusa_output.on_output do |message|
          message_bus.write Messages::Runner::Results.new(output: message, file: file)
        end        

        setup_environment(file, medusa_output)

        @configuration.reporter.report(@world.example_count, @configuration.randomize? ? @configuration.seed : nil) do |reporter|
          begin
            @configuration.run_hook(:before, :suite)
            @world.example_groups.ordered.map {|g| g.run(reporter)}.all? ? 0 : @configuration.failure_exit_code
          ensure
            @configuration.run_hook(:after, :suite)
          end
        end
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
          @core_config   = RSpec::configuration.dup
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
