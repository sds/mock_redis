require 'spec_helper'

RSpec.describe '#incr(key)' do
  before { @key = 'mock-redis-test:33888' }

  it 'returns the value after the increment' do
    @redises.set(@key, 1)
    expect(@redises.incr(@key)).to eq(2)
  end

  it 'treats a missing key like 0' do
    expect(@redises.incr(@key)).to eq(1)
  end

  it 'increments negative numbers' do
    @redises.set(@key, -10)
    expect(@redises.incr(@key)).to eq(-9)
  end

  it 'works multiple times' do
    expect(@redises.incr(@key)).to eq(1)
    expect(@redises.incr(@key)).to eq(2)
    expect(@redises.incr(@key)).to eq(3)
  end

  it 'raises an error if the value does not look like an integer' do
    @redises.set(@key, 'one')
    expect do
      @redises.incr(@key)
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a string-only command'
end
