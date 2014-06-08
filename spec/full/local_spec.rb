require 'spec_helper'
require 'pathname'

class TestResultCapture
  attr_reader :results

  def initialize
    @results = []
  end

  def report_work_result(result)
    @results << [result.name, result.success?]
  end

  def message(string)
    @results << string
  end
end

describe "Local execution" do
  let(:spec_files) { Dir.glob(Pathname.new(__FILE__).dirname.join("../fixtures/*_spec.rb").to_s) }

  it "runs the spec files correctly" do
    port_start = 18100

    begin
      labrynth_pid = fork do
        Medusa.register_driver Medusa::Drivers::RspecDriver.new

        labrynth = Medusa::Labrynth.new("localhost:#{port_start}")
        labrynth.dungeons << Medusa::Dungeon.new(2, 41010)
        labrynth.serve!
      end

      sleep(1)

      Medusa.dungeon_discovery.add_labrynth("localhost:#{port_start}")

      reporter = TestResultCapture.new

      overlord = Medusa::Overlord.new
      overlord.keepers << Medusa::Keeper.new
      overlord.prepare!

      overlord.add_work(spec_files)
      overlord.reporters << reporter
      overlord.work!

      expect(reporter).to have(6).results
    ensure
      Process.kill("KILL", labrynth_pid)
    end
  end
end
