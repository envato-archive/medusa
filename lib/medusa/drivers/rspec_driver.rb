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
          '-f', 'RSpec::Core::Formatters::MedusaFormatter',
          file
        ]

        result = Result.new

        begin
          RSpec.instance_variable_set(:@world, nil)
          RSpec::Core::Runner.run(config, medusa_output, medusa_output)

          medusa_output.rewind
          output = JSON(medusa_output.read.chomp)

          output[:tests].each do |results|
            status = results[:status]

            if status == :passed
              result.inc_passed!
            elsif status == :pending
              result.inc_pending!($1)
            elsif status == :failed
              result.inc_failed!($1, results[:exception])
            end
          end
        rescue => ex
          result.fatal!(ex.message, ex.backtrace)
        end

        return result
      end
    end
  end
end
