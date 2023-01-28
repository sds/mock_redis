require 'spec_helper'

RSpec.describe '#setnx(key, value)' do
  before { @key = 'mock-redis-test:setnx' }

  it 'returns true if the key was absent' do
    expect(@redises.setnx(@key, 1)).to eq(true)
  end

  it 'returns false if the key was present' do
    @redises.set(@key, 2)
    expect(@redises.setnx(@key, 1)).to eq(false)
  end

  it 'sets the value if missing' do
    @redises.setnx(@key, 'value')
    expect(@redises.get(@key)).to eq('value')
  end

  it 'does nothing if the value is present' do
    @redises.set(@key, 'old')
    @redises.setnx(@key, 'new')
    expect(@redises.get(@key)).to eq('old')
  end
end
