require 'spec_helper'

RSpec.describe '#hvals(key)' do
  before do
    @key = 'mock-redis-test:hvals'
    @redises.hset(@key, 'k1', 'v1')
    @redises.hset(@key, 'k2', 'v2')
  end

  it 'returns the values stored in the hash' do
    expect(@redises.hvals(@key).sort).to eq(%w[v1 v2])
  end

  it 'returns [] when there is no such key' do
    expect(@redises.hvals('mock-redis-test:nonesuch')).to eq([])
  end

  it_should_behave_like 'a hash-only command'
end
