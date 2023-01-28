require 'spec_helper'

RSpec.describe '#hincrby(key, field, increment)' do
  before do
    @key = 'mock-redis-test:hincrby'
    @field = 'count'
  end

  it 'returns the value after the increment' do
    @redises.hset(@key, @field, 2)
    expect(@redises.hincrby(@key, @field, 2)).to eq(4)
  end

  it 'treats a missing key like 0' do
    expect(@redises.hincrby(@key, @field, 1)).to eq(1)
  end

  it 'creates a hash if nothing is present' do
    @redises.hincrby(@key, @field, 1)
    expect(@redises.hget(@key, @field)).to eq('1')
  end

  it 'increments negative numbers' do
    @redises.hset(@key, @field, -10)
    expect(@redises.hincrby(@key, @field, 2)).to eq(-8)
  end

  it 'works multiple times' do
    expect(@redises.hincrby(@key, @field, 2)).to eq(2)
    expect(@redises.hincrby(@key, @field, 2)).to eq(4)
    expect(@redises.hincrby(@key, @field, 2)).to eq(6)
  end

  it 'accepts an integer-ish string' do
    expect(@redises.hincrby(@key, @field, '2')).to eq(2)
  end

  it 'treats the field as a string' do
    field = 11
    @redises.hset(@key, field, 2)
    expect(@redises.hincrby(@key, field, 2)).to eq(4)
  end

  it 'raises an error if the value does not look like an integer' do
    @redises.hset(@key, @field, 'one')
    expect do
      @redises.hincrby(@key, @field, 1)
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if the delta does not look like an integer' do
    expect do
      @redises.hincrby(@key, @field, 'foo')
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a hash-only command'
end
