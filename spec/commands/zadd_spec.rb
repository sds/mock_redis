require 'spec_helper'

describe "#zadd(key, score, member)" do
  before { @key = 'mock-redis-test:zadd' }

  it "returns true if member wasn't present in the set" do
    @redises.zadd(@key, 1, 'foo').should be_true
  end

  it "returns false if member was present in the set" do
    @redises.zadd(@key, 1, 'foo')
    @redises.zadd(@key, 1, 'foo').should be_false
  end

  it "adds member to the set" do
    @redises.zadd(@key, 1, 'foo')
    @redises.zrange(@key, 0, -1).should == ['foo']
  end

  it "updates the score" do
    @redises.zadd(@key, 1, 'foo')
    @redises.zadd(@key, 2, 'foo')

    @redises.zscore(@key, 'foo').should == "2"
  end

  it_should_behave_like "arg 1 is a score"
  it_should_behave_like "a zset-only command"
end
