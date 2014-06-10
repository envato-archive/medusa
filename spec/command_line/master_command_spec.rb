require 'spec_helper'
require 'medusa/cli'

describe Medusa::CommandLine::MasterCommand do
  context "files" do
    subject(:command) do
      described_class.new({}, [__FILE__], {})
    end

    let(:overlord) do
      Medusa::Overlord.new
    end

    it "provides the files to an Overlord" do
      allow(Medusa::Overlord).to receive(:new).and_return(overlord)
      allow(overlord).to receive(:prepare!)

      command.execute

      overlord.work.should == [__FILE__]
    end
  end
end