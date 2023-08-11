require 'spec_helper'

RSpec.describe '#msetnx(key, value [, key, value, ...])' do
  before do
    @key1 = 'mock-redis-test:msetnx1'
    @key2 = 'mock-redis-test:msetnx2'
  end

  it 'responds with 1 if any keys were set' do
    expect(@redises.msetnx(@key1, 1)).to eq(true)
  end

  it 'sets the values' do
    @redises.msetnx(@key1, 'value1', @key2, 'value2')
    expect(@redises.mget(@key1, @key2)).to eq(%w[value1 value2])
  end

  it 'does nothing if any value is already set' do
    @redises.set(@key1, 'old1')
    @redises.msetnx(@key1, 'value1', @key2, 'value2')
    expect(@redises.mget(@key1, @key2)).to eq(['old1', nil])
  end

  it 'responds with 0 if any value is already set' do
    @redises.set(@key1, 'old1')
    expect(@redises.msetnx(@key1, 'value1', @key2, 'value2')).to eq(false)
  end

  it 'raises an error if given an odd number of arguments' do
    expect do
      @redises.msetnx(@key1, 'value1', @key2)
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if given 0 arguments' do
    expect do
      @redises.msetnx
    end.to raise_error(Redis::CommandError)
  end
end
