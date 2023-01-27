require 'spec_helper'

RSpec.describe '#exists(*keys)' do
  before { @key1 = 'mock-redis-test:exists1' }
  before { @key2 = 'mock-redis-test:exists2' }

  it 'returns 0 for keys that do not exist' do
    expect(@redises.exists(@key1)).to eq(0)
    expect(@redises.exists(@key1, @key2)).to eq(0)
  end

  it 'returns 1 for keys that do exist' do
    @redises.set(@key1, 1)
    expect(@redises.exists(@key1)).to eq(1)
  end

  it 'returns the count of all keys that exist' do
    @redises.set(@key1, 1)
    @redises.set(@key2, 1)
    expect(@redises.exists(@key1, @key2)).to eq(2)
    expect(@redises.exists(@key1, @key2, 'does-not-exist')).to eq(2)
  end
end

RSpec.describe '#exists?(*keys)' do
  before { @key1 = 'mock-redis-test:exists1' }
  before { @key2 = 'mock-redis-test:exists2' }

  it 'returns false for keys that do not exist' do
    expect(@redises.exists?(@key1)).to eq(false)
    expect(@redises.exists?(@key1, @key2)).to eq(false)
  end

  it 'returns true for keys that do exist' do
    @redises.set(@key1, 1)
    expect(@redises.exists?(@key1)).to eq(true)
  end

  it 'returns true if any keys exist' do
    @redises.set(@key2, 1)
    expect(@redises.exists?(@key1, @key2)).to eq(true)
  end
end
