require 'spec_helper'

RSpec.describe '#zrem(key, member)' do
  before do
    @key = 'mock-redis-test:zrem'

    @redises.zadd(@key, 1, 'one')
    @redises.zadd(@key, 2, 'two')
  end

  it 'returns true if member is present in the set' do
    expect(@redises.zrem(@key, 'one')).to eq(true)
  end

  it 'returns false if member is not present in the set' do
    expect(@redises.zrem(@key, 'nobody home')).to eq(false)
  end

  it 'removes member from the set' do
    @redises.zrem(@key, 'one')
    expect(@redises.zrange(@key, 0, -1)).to eq(['two'])
  end

  it 'removes integer member from the set' do
    member = 11
    @redises.zadd(@key, 3, member)
    expect(@redises.zrem(@key, member)).to eq(true)
    expect(@redises.zrange(@key, 0, -1)).to eq(%w[one two])
  end

  it 'removes integer members inside an array from the set' do
    member = 11
    @redises.zadd(@key, 3, member)
    expect(@redises.zrem(@key, [member])).to eq(1)
    expect(@redises.zrange(@key, 0, -1)).to eq(%w[one two])
  end

  it 'supports a variable number of arguments' do
    @redises.zrem(@key, %w[one two])
    expect(@redises.zrange(@key, 0, -1)).to be_empty
  end

  it 'raises an error if member is an empty array' do
    expect do
      @redises.zrem(@key, [])
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a zset-only command'
end
