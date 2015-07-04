require 'spec_helper'

describe '#spop(key)' do
  before do
    @key = 'mock-redis-test:spop'

    @redises.sadd(@key, 'value')
  end

  it 'returns a member of the set' do
    @redises.spop(@key).should == 'value'
  end

  it 'removes a member of the set' do
    @redises.spop(@key)
    @redises.smembers(@key).should == []
  end

  it 'returns nil if the set is empty' do
    @redises.spop(@key)
    @redises.spop(@key).should be_nil
  end

  it_should_behave_like 'a set-only command'
end
