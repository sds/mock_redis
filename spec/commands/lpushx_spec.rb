require 'spec_helper'

describe "#lpushx(key, value)" do
  before { @key = 'mock-redis-test:81267' }

  it "returns the new size of the list" do
    @redises.lpush(@key, 'X')

    @redises.lpushx(@key, 'X').should == 2
    @redises.lpushx(@key, 'X').should == 3
  end

  it "does nothing when run against a nonexistent key" do
    @redises.lpushx(@key, 'value')
    @redises.get(@key).should be_nil
  end

  it "prepends items to the list" do
    @redises.lpush(@key, "bert")
    @redises.lpushx(@key, "ernie")

    @redises.lindex(@key, 0).should == "ernie"
    @redises.lindex(@key, 1).should == "bert"
  end

  it "raises an error when run against a non-list" do
    @redises.set(@key, 'string value')
    lambda do
      @redises.lpushx(@key, 1)
    end.should raise_error(RuntimeError)
  end

  it "stores values as strings" do
    @redises.lpush(@key, 1)
    @redises.lpushx(@key, 2)
    @redises.lindex(@key, 0).should == "2"
  end
end
