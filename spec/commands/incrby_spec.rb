require 'spec_helper'

RSpec.describe '#incrby(key, increment)' do
  before { @key = 'mock-redis-test:65374' }

  it 'returns the value after the increment' do
    @redises.set(@key, 2)
    expect(@redises.incrby(@key, 2)).to eq(4)
  end

  it 'treats a missing key like 0' do
    expect(@redises.incrby(@key, 1)).to eq(1)
  end

  it 'increments negative numbers' do
    @redises.set(@key, -10)
    expect(@redises.incrby(@key, 2)).to eq(-8)
  end

  it 'works multiple times' do
    expect(@redises.incrby(@key, 2)).to eq(2)
    expect(@redises.incrby(@key, 2)).to eq(4)
    expect(@redises.incrby(@key, 2)).to eq(6)
  end

  it 'accepts an integer-ish string' do
    expect(@redises.incrby(@key, '2')).to eq(2)
  end

  it 'raises an error if the value does not look like an integer' do
    @redises.set(@key, 'one')
    expect do
      @redises.incrby(@key, 1)
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if the delta does not look like an integer' do
    expect do
      @redises.incrby(@key, 'foo')
    end.to raise_error(ArgumentError)
  end

  it_should_behave_like 'a string-only command'
end
