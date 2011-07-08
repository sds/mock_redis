require 'spec_helper'

describe "#rpush(key)" do
  before { @key = "mock-redis-test:#{__FILE__}" }

  it "returns the new size of the list" do
    @redises.rpush(@key, 'X').should == 1
    @redises.rpush(@key, 'X').should == 2
  end

  it "creates a new list when run against a nonexistent key" do
    @redises.rpush(@key, 'value')
    @redises.llen(@key).should == 1
  end

  it "appends items to the list" do
    @redises.rpush(@key, "bert")
    @redises.rpush(@key, "ernie")

    @redises.lindex(@key, 0).should == "bert"
    @redises.lindex(@key, 1).should == "ernie"
  end

  it "raises an error when run against a non-list" do
    @redises.set(@key, 'string value')
    lambda do
      @redises.rpush(@key, 1)
    end.should raise_error(RuntimeError)
  end

  it "stores values as strings" do
    @redises.rpush(@key, 1)
    @redises.lindex(@key, 0).should == "1"
  end
end
