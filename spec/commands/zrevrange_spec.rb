require 'spec_helper'

RSpec.describe '#zrevrange(key, start, stop [, :with_scores => true])' do
  before do
    @key = 'mock-redis-test:zrevrange'
    @redises.zadd(@key, 1, 'Washington')
    @redises.zadd(@key, 2, 'Adams')
    @redises.zadd(@key, 3, 'Jefferson')
    @redises.zadd(@key, 4, 'Madison')
  end

  context 'when the zset is empty' do
    before do
      @redises.del(@key)
    end

    it 'should return an empty array' do
      expect(@redises.exists?(@key)).to eq(false)
      expect(@redises.zrevrange(@key, 0, 4)).to eq([])
    end
  end

  it 'returns the elements in order by score' do
    expect(@redises.zrevrange(@key, 0, 1)).to eq(%w[Madison Jefferson])
  end

  context 'when a subset of elements have the same score' do
    before do
      @redises.zadd(@key, 1, 'Martha')
    end

    it 'returns the elements in descending lexicographical order' do
      expect(@redises.zrevrange(@key, 3, 4)).to eq(%w[Washington Martha])
    end
  end

  it 'returns the elements in order by score (negative indices)' do
    expect(@redises.zrevrange(@key, -2, -1)).to eq(%w[Adams Washington])
  end

  it 'returns empty list when start is too large' do
    expect(@redises.zrevrange(@key, 5, -1)).to eq([])
  end

  it 'returns the scores when :with_scores is specified' do
    expect(@redises.zrevrange(@key, 2, 3, :with_scores => true)).
      to eq([['Adams', 2.0], ['Washington', 1.0]])
  end

  it 'returns the scores when :withscores is specified' do
    expect(@redises.zrevrange(@key, 2, 3, :withscores => true)).
      to eq([['Adams', 2.0], ['Washington', 1.0]])
  end

  it_should_behave_like 'a zset-only command'
end
