require 'spec_helper'

RSpec.describe '#hget(key, field)' do
  before do
    @key = 'mock-redis-test:hget'
    @redises.hset(@key, 'k1', 'v1')
    @redises.hset(@key, 'k2', 'v2')
  end

  it 'returns the value stored at field' do
    expect(@redises.hget(@key, 'k1')).to eq('v1')
  end

  it 'treats the field as a string' do
    @redises.hset(@key, '3', 'v3')
    expect(@redises.hget(@key, 3)).to eq('v3')
  end

  it 'returns nil when there is no such field' do
    expect(@redises.hget(@key, 'nonesuch')).to be_nil
  end

  it 'returns nil when there is no such key' do
    expect(@redises.hget('mock-redis-test:nonesuch', 'k1')).to be_nil
  end

  it_should_behave_like 'a hash-only command'
end
