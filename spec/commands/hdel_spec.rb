require 'spec_helper'

describe '#hdel(key, field)' do
  before do
    @key = 'mock-redis-test:hdel'
    @redises.hset(@key, 'k1', 'v1')
    @redises.hset(@key, 'k2', 'v2')
  end

  it 'returns 1 when it removes a field' do
    @redises.hdel(@key, 'k1').should == 1
  end

  it 'returns 0 when it does not remove a field' do
    @redises.hdel(@key, 'nonesuch').should == 0
  end

  it 'actually removes the field' do
    @redises.hdel(@key, 'k1')
    @redises.hget(@key, 'k1').should be_nil
  end

  it 'treats the field as a string' do
    field = 2
    @redises.hset(@key, field, 'two')
    @redises.hdel(@key, field)
    @redises.hget(@key, field).should be_nil
  end

  it 'removes only the field specified' do
    @redises.hdel(@key, 'k1')
    @redises.hget(@key, 'k2').should == 'v2'
  end

  it 'cleans up empty hashes' do
    @redises.hdel(@key, 'k1')
    @redises.hdel(@key, 'k2')
    @redises.get(@key).should be_nil
  end

  it 'supports a variable number of arguments' do
    @redises.hdel(@key, %w[k1 k2])
    @redises.get(@key).should be_nil
  end

  it 'treats variable arguments as strings' do
    field = 2
    @redises.hset(@key, field, 'two')
    @redises.hdel(@key, [field])
    @redises.hget(@key, field).should be_nil
  end

  it_should_behave_like 'a hash-only command'
end
