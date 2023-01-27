require 'spec_helper'

RSpec.describe '#scard(key)' do
  before { @key = 'mock-redis-test:scard' }

  it 'returns 0 for an empty set' do
    expect(@redises.scard(@key)).to eq(0)
  end

  it 'returns the number of elements in the set' do
    @redises.sadd(@key, 'one')
    @redises.sadd(@key, 'two')
    @redises.sadd(@key, 'three')
    expect(@redises.scard(@key)).to eq(3)
  end

  it_should_behave_like 'a set-only command'
end
