require 'spec_helper'

describe "#zrange(key, start, stop [, :with_scores => true])" do
  before do
    @key = 'mock-redis-test:zrange'
    @redises.zadd(@key, 1, 'Washington')
    @redises.zadd(@key, 2, 'Adams')
    @redises.zadd(@key, 3, 'Jefferson')
    @redises.zadd(@key, 4, 'Madison')
  end

  it "returns the elements when the range is given as strings" do
    @redises.zrange(@key, "0", "1").should == ['Washington', 'Adams']
  end

  it "returns the elements in order by score" do
    @redises.zrange(@key, 0, 1).should == ['Washington', 'Adams']
  end

  it "returns the elements in order by score (negative indices)" do
    @redises.zrange(@key, -2, -1).should == ['Jefferson', 'Madison']
  end

  it 'returns empty list when start is too large' do
    @redises.zrange(@key, 5, -1).should == []
  end

  it "returns the scores when :with_scores is specified" do
    @redises.zrange(@key, 0, 1, :with_scores => true).
      should == [["Washington", 1.0], ["Adams", 2.0]]
  end

  it "returns the scores when :withscores is specified" do
    @redises.zrange(@key, 0, 1, :withscores => true).
      should == [["Washington", 1.0], ["Adams", 2.0]]
  end

  it_should_behave_like "a zset-only command"
end
