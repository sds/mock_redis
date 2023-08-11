require 'spec_helper'

RSpec.describe '#hexists(key, field)' do
  before do
    @key = 'mock-redis-test:hexists'
    @redises.hset(@key, 'field', 'value')
  end

  it 'returns true if the hash has that field' do
    expect(@redises.hexists(@key, 'field')).to eq(true)
  end

  it 'returns false if the hash lacks that field' do
    expect(@redises.hexists(@key, 'nonesuch')).to eq(false)
  end

  it 'treats the field as a string' do
    @redises.hset(@key, 1, 'one')
    expect(@redises.hexists(@key, 1)).to eq(true)
  end

  it 'returns nil when there is no such key' do
    expect(@redises.hexists('mock-redis-test:nonesuch', 'key')).to eq(false)
  end

  it_should_behave_like 'a hash-only command'
end
