require 'spec_helper'

RSpec.describe '#decrby(key, decrement)' do
  before { @key = 'mock-redis-test:43650' }

  it 'returns the value after the decrement' do
    @redises.set(@key, 4)
    expect(@redises.decrby(@key, 2)).to eq(2)
  end

  it 'treats a missing key like 0' do
    expect(@redises.decrby(@key, 2)).to eq(-2)
  end

  it 'decrements negative numbers' do
    @redises.set(@key, -10)
    expect(@redises.decrby(@key, 2)).to eq(-12)
  end

  it 'works multiple times' do
    expect(@redises.decrby(@key, 2)).to eq(-2)
    expect(@redises.decrby(@key, 2)).to eq(-4)
    expect(@redises.decrby(@key, 2)).to eq(-6)
  end

  it 'raises an error if the value does not look like an integer' do
    @redises.set(@key, 'one')
    expect do
      @redises.decrby(@key, 1)
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a string-only command'
end
