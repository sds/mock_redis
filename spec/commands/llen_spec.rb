require 'spec_helper'

describe "#llen" do
  before { @key = 'mock-redis-test:78407' }

  it "returns 0 for a nonexistent key" do
    @redises.llen(@key).should == 0
  end

  it "returns the length of the list" do
    5.times { @redises.lpush(@key, 'X') }
    @redises.llen(@key).should == 5
  end

  it "raises an error when the value at key is not a list" do
    @redises.set(@key, "string value")
    lambda do
      @redises.llen(@key)
    end.should raise_error(RuntimeError)
  end
end
