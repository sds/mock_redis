require 'spec_helper'

RSpec.describe '#hset(key, field)' do
  before do
    @key = 'mock-redis-test:hset'
  end

  it 'returns 1 if the key does not exist' do
    expect(@redises.hset(@key, 'k1', 'v1')).to eq(1)
  end

  it 'returns 1 if the key exists but the field does not' do
    @redises.hset(@key, 'k1', 'v1')
    expect(@redises.hset(@key, 'k2', 'v2')).to eq(1)
  end

  it 'returns 0 if the field already exists' do
    @redises.hset(@key, 'k1', 'v1')
    expect(@redises.hset(@key, 'k1', 'v1')).to eq(0)
  end

  it 'creates a hash there is no such field' do
    @redises.hset(@key, 'k1', 'v1')
    expect(@redises.hget(@key, 'k1')).to eq('v1')
  end

  it 'stores values as strings' do
    @redises.hset(@key, 'num', 1)
    expect(@redises.hget(@key, 'num')).to eq('1')
  end

  it 'stores fields as strings' do
    @redises.hset(@key, 1, 'one')
    expect(@redises.hget(@key, '1')).to eq('one')
  end

  it 'stores fields sent in a hash' do
    expect(@redises.hset(@key, { 'k1' => 'v1', 'k2' => 'v2' })).to eq(2)
  end

  it 'stores array values correctly' do
    @redises.hset(@key, %w[k1 v1 k2 v2])
    expect(@redises.hget(@key, 'k1')).to eq('v1')
    expect(@redises.hget(@key, 'k2')).to eq('v2')
  end

  it 'raises error when key is nil' do
    expect do
      @redises.hset(nil, 'abc')
    end.to raise_error(TypeError)
  end

  it 'raises error when hash key is nil' do
    expect do
      @redises.hset(@key, nil, 'abc')
    end.to raise_error(TypeError)
  end

  it 'stores multiple arguments correctly' do
    @redises.hset(@key, 'k1', 'v1', 'k2', 'v2')
    expect(@redises.hget(@key, 'k1')).to eq('v1')
    expect(@redises.hget(@key, 'k2')).to eq('v2')
  end

  it_should_behave_like 'a hash-only command'
end
