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

        medusa_output = StringIO.new

        config = [
          '-f',
          'RSpec::Core::Formatters::MedusaFormatter',
          file
        ]

        RSpec.instance_variable_set(:@world, nil)
        RSpec::Core::Runner.run(config, medusa_output, medusa_output)

        medusa_output.rewind
        result = medusa_output.read.chomp

        return result
      end
    end
  end
end
