require 'spec_helper'
require 'pathname'

class TestResultCapture
  attr_reader :results

  def initialize
    @results = []
  end

  def report_work_result(result)
    @results << [:work_result, result.name, result.success?, result]
  end

  def report_work_complete(file)
    @results << [:file_complete, file]
  end

  def message(string)
    @results << string
  end
end

describe "Local execution" do
  let(:spec_file) { Pathname.new(__FILE__).dirname.join("../fixtures/sample_spec.rb").to_s }

  it "runs the spec files correctly" do
    labyrinth_port = 18000 + rand(10000)

    begin
      labyrinth_pid = fork do
        Medusa.register_driver Medusa::Drivers::RspecDriver.new

        labyrinth = Medusa::Labyrinth.new("localhost:#{labyrinth_port}")
        labyrinth.dungeons << Medusa::Dungeon.new(2)
        labyrinth.serve!
      end

      sleep(0.1) until Medusa::Labyrinth.available_at?("localhost:#{labyrinth_port}")

      Medusa.dungeon_discovery.add_labyrinth("localhost:#{labyrinth_port}")

      reporter = TestResultCapture.new

      overlord = Medusa::Overlord.new
      overlord.keepers << Medusa::Keeper.new
      overlord.prepare!

      overlord.add_work(spec_file)
      overlord.reporters << reporter
      overlord.work!

      expect(reporter).to have(2).results
      expect(reporter.results[0][0]).to eql :work_result
      expect(reporter.results[1][0]).to eql :file_complete

      expect(reporter.results[0][3].stdout).to eql "Checking one == one"
    ensure
      Process.kill("KILL", labyrinth_pid)
    end
  end
end
