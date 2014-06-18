require 'spec_helper'

describe "Union and Minion" do
  let(:dungeon) { double("Dungeon", name: "Something", location: Pathname.new(__FILE__).dirname) }
  let(:keeper) { double("Keeper", name: "Something") }
  let(:reporter) { TestReporter.new }

  let(:logger) { Medusa.logger.tagged("TEST") }

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

    logger.info("Delegating work")

    union.delegate(:work!, Pathname.new(__FILE__).dirname.join("../fixtures/sample_spec.rb").to_s)

    logger.info("Waiting for complete")

    union.wait_for_complete
    union.finished

    logger.info("Verifying")

    expect(reporter).to have(2).results
    
    test_results = reporter.get_results_by_class(String)
    expect(test_results.length).to eql 1
    expect(test_results.first).to eql "Started" # Sent by the TestDriver.

    test_results = reporter.get_results_by_class(Medusa::Messages::FileComplete)
    expect(test_results.length).to eql 1
  end
end
