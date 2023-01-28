require 'spec_helper'

RSpec.describe '#mapped_hmset(key, hash={})' do
  before do
    @key = 'mock-redis-test:mapped_hmset'
  end

  it "returns 'OK'" do
    expect(@redises.mapped_hmset(@key, 'k1' => 'v1', 'k2' => 'v2')).to eq('OK')
  end

  it 'sets the values' do
    @redises.mapped_hmset(@key, 'k1' => 'v1', 'k2' => 'v2')
    expect(@redises.hmget(@key, 'k1', 'k2')).to eq(%w[v1 v2])
  end

  it 'updates an existing hash' do
    @redises.hmset(@key, 'foo', 'bar')
    @redises.mapped_hmset(@key, 'bert' => 'ernie', 'diet' => 'coke')

    expect(@redises.hmget(@key, 'foo', 'bert', 'diet')).
      to eq(%w[bar ernie coke])
  end

  it 'stores the values as strings' do
    @redises.mapped_hmset(@key, 'one' => 1)
    expect(@redises.hget(@key, 'one')).to eq('1')
  end

  it 'raises an error if given no hash' do
    expect do
      @redises.mapped_hmset(@key)
    end.to raise_error(ArgumentError)
  end

  it 'raises an error if given a an odd length array' do
    expect do
      @redises.mapped_hmset(@key, [1])
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if given a non-hash value' do
    expect do
      @redises.mapped_hmset(@key, 1)
    end.to raise_error(NoMethodError)
  end
end
