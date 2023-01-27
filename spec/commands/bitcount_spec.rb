require 'spec_helper'

RSpec.describe '#bitcount(key [, start, end ])' do
  before do
    @key = 'mock-redis-test:bitcount'
    @redises.set(@key, 'foobar')
  end

  it 'gets the number of set bits from the key' do
    expect(@redises.bitcount(@key)).to eq(26)
  end

  it 'gets the number of set bits from the key in an interval' do
    expect(@redises.bitcount(@key, 0, 1000)).to eq(26)
    expect(@redises.bitcount(@key, 0, 0)).to eq(4)
    expect(@redises.bitcount(@key, 1, 1)).to eq(6)
    expect(@redises.bitcount(@key, 1, -2)).to eq(18)
  end

  it 'treats nonexistent keys as empty strings' do
    expect(@redises.bitcount('mock-redis-test:not-found')).to eq(0)
  end

  it_should_behave_like 'a string-only command'
end
