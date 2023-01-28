require 'spec_helper'

RSpec.describe '#getbit(key, offset)' do
  before do
    @key = 'mock-redis-test:getbit'
    @redises.set(@key, 'h') # ASCII 0x68
  end

  it 'gets the bits from the key' do
    expect(@redises.getbit(@key, 0)).to eq(0)
    expect(@redises.getbit(@key, 1)).to eq(1)
    expect(@redises.getbit(@key, 2)).to eq(1)
    expect(@redises.getbit(@key, 3)).to eq(0)
    expect(@redises.getbit(@key, 4)).to eq(1)
    expect(@redises.getbit(@key, 5)).to eq(0)
    expect(@redises.getbit(@key, 6)).to eq(0)
    expect(@redises.getbit(@key, 7)).to eq(0)
  end

  it 'returns 0 for out-of-range bits' do
    expect(@redises.getbit(@key, 100)).to eq(0)
  end

  it 'does not modify the stored value for out-of-range bits' do
    @redises.getbit(@key, 100)
    expect(@redises.get(@key)).to eq('h')
  end

  it 'treats nonexistent keys as empty strings' do
    expect(@redises.getbit('mock-redis-test:not-found', 0)).to eq(0)
  end

  it_should_behave_like 'a string-only command'
end
