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

        config = [
          '-f',
          'RSpec::Core::Formatters::MedusaFormatter',
          file
        ]

        RSpec.instance_variable_set(:@world, nil)

        RSpec::Core::Runner.run(config, medusa_output, medusa_output)
      end
    end
  end
end
