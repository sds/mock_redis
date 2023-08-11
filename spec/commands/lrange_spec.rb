require 'spec_helper'

RSpec.describe '#lrange(key, start, stop)' do
  before do
    @key = 'mock-redis-test:68036'

    @redises.lpush(@key, 'v4')
    @redises.lpush(@key, 'v3')
    @redises.lpush(@key, 'v2')
    @redises.lpush(@key, 'v1')
    @redises.lpush(@key, 'v0')
  end

  it 'returns a subset of the list inclusive of the right end' do
    expect(@redises.lrange(@key, 0, 2)).to eq(%w[v0 v1 v2])
  end

  it 'returns a subset of the list when start and end are strings' do
    expect(@redises.lrange(@key, '0', '2')).to eq(%w[v0 v1 v2])
  end

  it 'returns an empty list when start > end' do
    expect(@redises.lrange(@key, 3, 2)).to eq([])
  end

  it 'works with a negative stop index' do
    expect(@redises.lrange(@key, 2, -1)).to eq(%w[v2 v3 v4])
  end

  it 'works with negative start and stop indices' do
    expect(@redises.lrange(@key, -2, -1)).to eq(%w[v3 v4])
  end

  it 'works with negative start indices less than list length' do
    expect(@redises.lrange(@key, -10, -2)).to eq(%w[v0 v1 v2 v3])
  end

  it 'returns [] when run against a nonexistent value' do
    expect(@redises.lrange('mock-redis-test:bogus-key', 0, 1)).to eq([])
  end

  it 'returns [] when start is too large' do
    expect(@redises.lrange(@key, 100, 100)).to eq([])
  end

  it 'finds the end of the list correctly when end is too large' do
    expect(@redises.lrange(@key, 4, 10)).to eq(%w[v4])
  end

  it_should_behave_like 'a list-only command'
end
