require 'spec_helper'

describe '#[](key)' do
  before do
    @key = 'mock-redis-test:hash_operator'
  end

  it 'returns nil for a nonexistent value' do
    @redises['mock-redis-test:does-not-exist'].should be_nil
  end

  it 'returns a stored string value' do
    @redises[@key] = 'forsooth'
    @redises[@key].should == 'forsooth'
  end

  it 'treats integers as strings' do
    @redises[@key] = 100
    @redises[@key].should == '100'
  end
end
