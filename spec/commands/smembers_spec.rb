require 'spec_helper'

describe '#smembers(key)' do
  before { @key = 'mock-redis-test:smembers' }

  it "returns [] for an empty set" do
    @redises.smembers(@key).should == []
  end

  it "returns the set's members" do
    @redises.sadd(@key, 1)
    @redises.sadd(@key, 2)
    @redises.sadd(@key, 3)
    @redises.smembers(@key).should == %w[1 2 3]
  end

  it_should_behave_like "a set-only command"
end
