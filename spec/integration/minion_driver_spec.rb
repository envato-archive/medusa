require 'spec_helper'

describe "Minion and Driver" do
  let(:dungeon) { double("Dungeon", name: "Something") }
  let(:keeper) { double("Keeper", name: "Something") }
  let(:reporter) { double("Reporter", report: true) }

  it "runs a spec" do
    Medusa.register_driver TestDriver.new

    minion = Medusa::Minion.new(dungeon, "Sam")
    minion.report_to(reporter)
    minion.receive_the_gift_of_life!(keeper, [])
    minion.work!(Pathname.new(__FILE__).dirname.join("../fixtures/sample_spec.rb").to_s)

    sleep(0.1) while !minion.free?

    expect(reporter).to have_received(:report).once
  end
end
