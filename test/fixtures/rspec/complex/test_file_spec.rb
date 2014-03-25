require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe "Some Situation" do
  some_standard_group
  
  it "should be a success" do
    expect(mixed_in_value).to eql 1
  end
end
