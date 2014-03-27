require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe "Some Situation" do
  it "shouldn't corrupt the output" do
    Thread.new { 100.times { puts "blah" } }
    expect(1).to eql 1
  end

  # it "should write to stdout" do
  #   puts "Whatever"
  #   expect(1).to eql 1
  # end
end
