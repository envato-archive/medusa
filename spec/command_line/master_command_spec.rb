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

    it "provides the files to an Overlord"
  end
end