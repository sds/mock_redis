require 'spec_helper'

describe '#sadd(key, member)' do
  before { @key = 'mock-redis-test:sadd' }

  it "returns 1 if the set did not already contain member" do
    @redises.sadd(@key, 1).should == 1
  end

  it "returns 0 if the set did already contain member" do
    @redises.sadd(@key, 1)
    @redises.sadd(@key, 1).should == 0
  end

  it "returns the number of newly added members" do
    @redises.sadd(@key, 1)
    @redises.sadd(@key, 1, 2, 3, 2).should == 2
  end

  it "adds member to the set" do
    @redises.sadd(@key, 1)
    @redises.sadd(@key, 2, 1)
    @redises.smembers(@key).should == %w[2 1]
  end

  it_should_behave_like "a set-only command"
end
