module Medusa
  module Drivers
    class CucumberDriver < Abstract

      def detect(file)
        file =~ /_spec\.rb$/
      end

      def execute(file)
        Test::Unit::AutoRunner.need_auto_run = false

        medusa_response = StringIO.new
        medusa_response.write("Running #{file}...")

        options = @options if @options.is_a?(Array)
        options = @options.split(' ') if @options.is_a?(String)

        output_file = File.expand_path("./tmp/medusa-cucumber-#{rand(1000000)}.log")
        system "touch #{output_file}"

        fork_id = fork do
          run_cuke(file, output_file, options)
        end

        Process.wait fork_id

        data = IO.read(output_file)
        system "rm #{output_file}"
        result = JSON.parse(data)

        extract_scenarios(result)
      end

      private

      def extract_scenarios(result)
        scenarios = []

        result.each do |result_node|
          if result_node['type'] == 'scenario'
            hash = {}

            scenario_steps = result_node['steps'].collect { |s| s['result'] }
            hash[:run_time] = scenario_steps.inject(0) { |t,i| t += i['duration'] } / 1000
            hash[:description] = result_node['name']
            hash[:status] = scenario_steps.all? { |s| s['status'] == 'passed' } ? 'passed' : 'failed'

            scenarios << hash
          else
            scenarios += extract_scenarios(result_node['elements']) if result_node['elements'].is_a?(Array)
          end
        end

        scenarios
      end

      def run_cuke(file, output_file, options)
        $0 = "[medusa] Cucumber"

        files = [file]
        dev_null = StringIO.new

        args = [file, options].flatten.compact
        # medusa_response.puts args.inspect

        results_directory = "#{Dir.pwd}/results/features"
        FileUtils.mkdir_p results_directory

        require 'cucumber/cli/main'

        Cucumber.logger.level = Logger::INFO

        cuke = Cucumber::Cli::Main.new(args, dev_null, dev_null)
        cuke.configuration.formats << ['Cucumber::Formatter::Json', output_file]

        cuke_runtime = Cucumber::Runtime.new(cuke.configuration)
        cuke_runtime.run!
      end

    end
  end
end