require 'spec_helper'

RSpec.describe '#decr(key)' do
  before { @key = 'mock-redis-test:46895' }

  it 'returns the value after the decrement' do
    @redises.set(@key, 2)
    expect(@redises.decr(@key)).to eq(1)
  end

  it 'treats a missing key like 0' do
    expect(@redises.decr(@key)).to eq(-1)
  end

  it 'decrements negative numbers' do
    @redises.set(@key, -10)
    expect(@redises.decr(@key)).to eq(-11)
  end

  it 'works multiple times' do
    expect(@redises.decr(@key)).to eq(-1)
    expect(@redises.decr(@key)).to eq(-2)
    expect(@redises.decr(@key)).to eq(-3)
  end

  it 'raises an error if the value does not look like an integer' do
    @redises.set(@key, 'minus one')
    expect do
      @redises.decr(@key)
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a string-only command'
end
