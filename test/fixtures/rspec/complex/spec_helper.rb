require 'rspec'

module SomeMixin
  def mixed_in_value
    1
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def some_standard_group
      context "within the standard tests" do
        it "should evaluate 1" do
          expect(1).to eql 1
        end
      end
    end
  end
end

RSpec.configure do |c|
  c.include(SomeMixin)
end