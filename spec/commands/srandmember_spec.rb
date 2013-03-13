require 'spec_helper'

describe '#srandmember(key)' do
  before do
    @key = 'mock-redis-test:srandmember'

    @redises.sadd(@key, 'value')
  end

  it "returns a member of the set" do
    @redises.srandmember(@key).should == 'value'
  end

  it "does not modify the set" do
    @redises.srandmember(@key)
    @redises.smembers(@key).should == ['value']
  end

  it "returns nil if the set is empty" do
    @redises.spop(@key)
    @redises.srandmember(@key).should be_nil
  end
end
