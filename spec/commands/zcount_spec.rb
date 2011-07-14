require 'spec_helper'

describe "#zcount(key, min, max)" do
  before do
    @key = 'mock-redis-test:zcount'
    @redises.zadd(@key, 1, 'Washington')
    @redises.zadd(@key, 2, 'Adams')
    @redises.zadd(@key, 3, 'Jefferson')
    @redises.zadd(@key, 4, 'Madison')
  end

  it "returns the number of members in the zset with scores in (min..max)" do
    @redises.zcount(@key, 3, 10).should == 2
  end

  it "returns 0 if there are no such members" do
    @redises.zcount(@key, 100, 200).should == 0
  end

  it_should_behave_like "arg 1 is a score"
  it_should_behave_like "arg 2 is a score"
  it_should_behave_like "a zset-only command"
end
