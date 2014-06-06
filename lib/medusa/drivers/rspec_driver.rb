
module Medusa
  module Drivers
    class RspecDriver
      def initialize
        require 'rspec'
        require 'medusa/spec/medusa_formatter'

        @logger = Medusa.logger.tagged(self.class.name)
      end

      def self.accept?(file)
        file =~ /_spec\.rb$/
      end

      def execute(file, minion)
        medusa_output = EventIO.new
        err = StringIO.new

        medusa_output.on_output do |message|
          if message.is_a?(Messages::TestResult)
            minion.inform_work_result message
          end
        end

        begin
          RSpec::Core::Formatters::MedusaFormatter.with_stdout do
            RSpec::Core::Runner.run(["-fRSpec::Core::Formatters::MedusaFormatter", file.to_s], err, medusa_output)
          end
        rescue => ex
          minion.inform_work_result Messages::TestResult.fatal_error(file, ex)
        end
      end
    end
  end
end