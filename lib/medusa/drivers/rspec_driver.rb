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

        RSpec.instance_variable_set(:@world, nil)
        RSpec::Core::Runner.run(config, medusa_output, medusa_output)

        medusa_output.rewind

        result = Result.new

        output = medusa_output.read.chomp.split("\n")

        output.each_with_index do |line, index|
          if line =~ /RSPECPASSED/
            result.inc_passed!
          elsif line =~ /RSPECPENDING: (.*)/
            result.inc_pending!($1)
          elsif line =~ /RSPECFAILED: (.*)/
            result.inc_failed!($1, grab_exception(output, index + 1))
          end
        end

        return result
      end

      private

      def grab_exception(lines, index)
        exception = []

        lines[index..-1].each do |line|
          break if line =~ /--ENDRSPECFAILED--/
          exception << line
        end

        return exception.join("\n")
      end

    end
  end
end