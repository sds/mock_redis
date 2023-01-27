require 'spec_helper'

RSpec.describe '#type(key)' do
  before do
    @key = 'mock-redis-test:type'
  end

  it "returns 'none' for no key" do
    expect(@redises.type(@key)).to eq('none')
  end

  it "returns 'string' for a string" do
    @redises.set(@key, 'stringlish')
    expect(@redises.type(@key)).to eq('string')
  end

  it "returns 'list' for a list" do
    @redises.lpush(@key, 100)
    expect(@redises.type(@key)).to eq('list')
  end

  it "returns 'hash' for a hash" do
    @redises.hset(@key, 100, 200)
    expect(@redises.type(@key)).to eq('hash')
  end

  it "returns 'set' for a set" do
    @redises.sadd(@key, 100)
    expect(@redises.type(@key)).to eq('set')
  end

  it "returns 'zset' for a zset" do
    @redises.zadd(@key, 1, 2)
    expect(@redises.type(@key)).to eq('zset')
  end
end
