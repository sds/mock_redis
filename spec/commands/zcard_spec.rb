require 'spec_helper'

RSpec.describe '#zcard(key)' do
  before do
    @key = 'mock-redis-test:zcard'
  end

  it 'returns the number of elements in the zset' do
    @redises.zadd(@key, 1, 'Washington')
    @redises.zadd(@key, 2, 'Adams')
    expect(@redises.zcard(@key)).to eq(2)
  end

  it 'returns 0 for nonexistent sets' do
    expect(@redises.zcard(@key)).to eq(0)
  end

  it_should_behave_like 'a zset-only command'
end
