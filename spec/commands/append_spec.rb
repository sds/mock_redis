require 'spec_helper'

RSpec.describe '#append(key, value)' do
  before { @key = 'mock-redis-test:append' }

  it 'returns the new length of the string' do
    @redises.set(@key, 'porkchop')
    expect(@redises.append(@key, 'sandwiches')).to eq(18)
  end

  it 'appends value to the previously-stored value' do
    @redises.set(@key, 'porkchop')
    @redises.append(@key, 'sandwiches')

    expect(@redises.get(@key)).to eq('porkchopsandwiches')
  end

  it 'treats a missing key as an empty string' do
    @redises.append(@key, 'foo')
    expect(@redises.get(@key)).to eq('foo')
  end

  it_should_behave_like 'a string-only command'
end
