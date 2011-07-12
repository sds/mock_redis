require 'spec_helper'

describe "#hgetall(key)" do
  before do
    @key = "mock-redis-test:hgetall"
    @redises.hset(@key, 'k1', 'v1')
    @redises.hset(@key, 'k2', 'v2')
  end

  it "returns the (key, value) pairs stored in the hash" do
    @redises.hgetall(@key).should == {
      'k1' => 'v1',
      'k2' => 'v2',
    }
  end

  it "returns [] when there is no such key" do
    @redises.hgetall('mock-redis-test:nonesuch').should == {}
  end

  it_should_behave_like "a hash-only command"
end
