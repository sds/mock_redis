require 'spec_helper'

describe '#sadd(key, member)' do
  before { @key = 'mock-redis-test:sadd' }

  it "returns true if the set did not already contain member" do
    @redises.sadd(@key, 1).should be_true
  end

  it "returns false if the set did already contain member" do
    @redises.sadd(@key, 1)
    @redises.sadd(@key, 1).should be_false
  end

  it "adds member to the set" do
    @redises.sadd(@key, 1)
    @redises.sadd(@key, 2)
    @redises.smembers(@key).should == %w[1 2]
  end

  it_should_behave_like "a set-only command"
end
