require 'spec_helper'

describe "#zrangebyscore(key, start, stop [:with_scores => true] [:limit => [offset count]])" do
  before do
    @key = 'mock-redis-test:zrangebyscore'
    @redises.zadd(@key, 1, 'Washington')
    @redises.zadd(@key, 2, 'Adams')
    @redises.zadd(@key, 3, 'Jefferson')
    @redises.zadd(@key, 4, 'Madison')
  end

  it "returns the elements in order by score" do
    @redises.zrangebyscore(@key, 1, 2).should == ['Washington', 'Adams']
  end

  it "returns the scores when :with_scores is specified" do
    @redises.zrangebyscore(@key, 1, 2, :with_scores => true).
      should == [["Washington", 1.0], ["Adams", 2.0]]
  end

  it "returns the scores when :withscores is specified" do
    @redises.zrangebyscore(@key, 1, 2, :withscores => true).
      should == [["Washington", 1.0], ["Adams", 2.0]]
  end

  it "honors the :limit => [offset count] argument" do
    @redises.zrangebyscore(@key, -100, 100, :limit => [1, 2]).
      should == ["Adams", "Jefferson"]
  end

  it "raises an error if :limit isn't a 2-tuple" do
    lambda do
      @redises.zrangebyscore(@key, -100, 100, :limit => [1, 2, 3])
    end.should raise_error(RuntimeError)

    lambda do
      @redises.zrangebyscore(@key, -100, 100, :limit => "1, 2")
    end.should raise_error
  end

  it "treats scores like floats, not strings" do
    @redises.zadd(@key, "10", "Tyler")
    @redises.zrangebyscore(@key, 1, 2).should == ['Washington', 'Adams']
  end

  it "treats -inf as negative infinity" do
    @redises.zrangebyscore(@key, "-inf", 3).should ==
      ["Washington", "Adams", "Jefferson"]
  end

  it "treats +inf as positive infinity" do
    @redises.zrangebyscore(@key, 3, "+inf").should == ["Jefferson", "Madison"]
  end

  it "treats +inf as positive infinity" do
    @redises.zrangebyscore(@key, 3, "+inf").should == ["Jefferson", "Madison"]
  end

  it "honors exclusive ranges on the left" do
    @redises.zrangebyscore(@key, "(3", 4).should == ["Madison"]
  end

  it "honors exclusive ranges on the right" do
    @redises.zrangebyscore(@key, "3", "(4").should == ["Jefferson"]
  end

  it_should_behave_like "a zset-only command"
end
