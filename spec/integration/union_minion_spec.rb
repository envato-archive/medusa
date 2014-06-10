require 'spec_helper'

describe "Union and Minion" do
  let(:dungeon) { double("Dungeon", name: "Something") }
  let(:keeper) { double("Keeper", name: "Something") }
  let(:reporter) { double("Reporter", report: true) }

  it "runs a spec" do
    Medusa.register_driver TestDriver.new

    minion = Medusa::Minion.new(dungeon, "Sam")
    minion.report_to(reporter)
    minion.receive_the_gift_of_life!(keeper, [])

    union = Medusa::Union.new(reporter)
    union.represent(minion)
    union.wait_for_ready
    union.provide_training([])
    union.wait_for_free

    union.delegate(:work!, Pathname.new(__FILE__).dirname.join("../fixtures/sample_spec.rb").to_s)

    union.wait_for_complete
    union.finished

    expect(reporter).to have_received(:report).twice
  end
end
