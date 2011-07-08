require 'spec_helper'

describe "#lpush" do
  before { @key = 'mock-redis-test:57367' }

  it "returns the new size of the list" do
    @redises.lpush(@key, 'X').should == 1
    @redises.lpush(@key, 'X').should == 2
  end

  it "creates a new list when run against a nonexistent key" do
    @redises.lpush(@key, 'value')
    @redises.llen(@key).should == 1
  end

  it "prepends items to the list" do
    @redises.lpush(@key, "bert")
    @redises.lpush(@key, "ernie")

    @redises.lindex(@key, 0).should == "ernie"
    @redises.lindex(@key, 1).should == "bert"
  end

  it "raises an error when run against a non-list" do
    @redises.set(@key, 'string value')
    lambda do
      @redises.lpush(@key, 1)
    end.should raise_error(RuntimeError)
  end

  it "stores values as strings" do
    @redises.lpush(@key, 1)
    @redises.lindex(@key, 0).should == "1"
  end
end
