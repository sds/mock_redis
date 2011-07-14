require 'spec_helper'

describe "#zrem(key, member)" do
  before do
    @key = 'mock-redis-test:zrem'

    @redises.zadd(@key, 1, 'one')
    @redises.zadd(@key, 2, 'two')
  end

  it "returns true if member is present in the set" do
    @redises.zrem(@key, 'one').should be_true
  end

  it "returns false if member is not present in the set" do
    @redises.zrem(@key, 'nobody home').should be_false
  end

  it "removes member from the set" do
    @redises.zrem(@key, 'one')
    @redises.zrange(@key, 0, -1).should == ['two']
  end

  it_should_behave_like "a zset-only command"
end
