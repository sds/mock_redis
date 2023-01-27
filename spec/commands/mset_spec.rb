require 'spec_helper'

RSpec.describe '#mset(key, value [, key, value, ...])' do
  before do
    @key1 = 'mock-redis-test:mset1'
    @key2 = 'mock-redis-test:mset2'
  end

  it "responds with 'OK'" do
    expect(@redises.mset(@key1, 1)).to eq('OK')
  end

  it "responds with 'OK' for passed Array with 1 item" do
    expect(@redises.mset([@key1, 1])).to eq('OK')
  end

  it "responds with 'OK' for passed Array with 2 items" do
    expect(@redises.mset([@key1, 1, @key2, 2])).to eq('OK')
  end

  it 'sets the values' do
    @redises.mset(@key1, 'value1', @key2, 'value2')
    expect(@redises.mget(@key1, @key2)).to eq(%w[value1 value2])
  end

  it 'raises an error if given an odd number of arguments' do
    expect do
      @redises.mset(@key1, 'value1', @key2)
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if given 0 arguments' do
    expect do
      @redises.mset
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if given odd-sized array' do
    expect do
      @redises.mset([@key1, 1, @key2])
    end.to raise_error(Redis::CommandError)
  end
end
