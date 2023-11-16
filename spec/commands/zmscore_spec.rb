require 'spec_helper'

RSpec.describe '#zmscore(key, member)' do
  before { @key = 'mock-redis-test:zmscore' }

  it 'returns the score as a string' do
    expect(@redises.zadd(@key, 0.25, 'foo')).to eq(true)
    expect(@redises.zmscore(@key, 'foo')).to eq([0.25])
  end

  it 'handles integer members correctly' do
    member = 11
    expect(@redises.zadd(@key, 0.25, member)).to eq(true)
    expect(@redises.zmscore(@key, member)).to eq([0.25])
  end

  it 'returns nil if member is not present in the set' do
    expect(@redises.zmscore(@key, 'foo')).to eq([nil])
  end

  it 'supports a variable number of arguments' do
    @redises.zadd(@key, [[1, 'one'], [2, 'two']])
    expect(@redises.zmscore(@key, 'one', 'three', 'two')).to eq([1, nil, 2])
  end

  it_should_behave_like 'a zset-only command'
end
