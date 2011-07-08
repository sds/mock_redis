require 'spec_helper'

describe "#lrange(key, start, stop)" do
  before do
    @key = 'mock-redis-test:68036'

    @redises.lpush(@key, 'v4')
    @redises.lpush(@key, 'v3')
    @redises.lpush(@key, 'v2')
    @redises.lpush(@key, 'v1')
    @redises.lpush(@key, 'v0')
  end

  it "returns a subset of the list inclusive of the right end" do
    @redises.lrange(@key, 0, 2).should == %w[v0 v1 v2]
  end

  it "returns an empty list when start > end" do
    @redises.lrange(@key, 3, 2).should == []
  end

  it "works with negative indices" do
    @redises.lrange(@key, 2, -1).should == %w[v2 v3 v4]
  end

  it "returns [] when run against a nonexistent value" do
    @redises.lrange("mock-redis-test:bogus-key", 0, 1).should == []
  end

  it "finds the end of the list correctly when end is too large" do
    @redises.lrange(@key, 4, 10).should == %w[v4]
  end

  it "raises an error when called on a non-list value" do
    @redises.set(@key, 'a string')

    lambda do
      @redises.lrange(@key, 0, -1)
    end.should raise_error(RuntimeError)
  end
end
