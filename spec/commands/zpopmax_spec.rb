require 'spec_helper'

RSpec.describe '#zpopmax(key, count)' do
  before(:each) do
    @key = 'mock-redis-test:zpopmax'
    @redises.del(@key)
    @redises.zadd(@key, 1, 'one')
    @redises.zadd(@key, 2, 'two')
    @redises.zadd(@key, 3, 'three')
  end

  context 'when count is unspecified' do
    it 'returns nil if the set does not exist' do
      expect(@redises.zpopmax('does-not-exist')).to be_nil
    end

    it 'returns the highest ranked element' do
      expect(@redises.zpopmax(@key)).to eq(['three', 3])
      expect(@redises.zcard(@key)).to eq(2)
    end
  end

  context 'when count is 1' do
    let(:count) { 1 }

    it 'returns nil if the set does not exist' do
      expect(@redises.zpopmax('does-not-exist', count)).to be_nil
    end

    it 'returns the highest ranked element' do
      expect(@redises.zpopmax(@key, count)).to eq(['three', 3])
      expect(@redises.zcard(@key)).to eq(2)
    end
  end

  context 'when count is greater than 1' do
    let(:count) { 2 }

    it 'returns empty array if the set does not exist' do
      expect(@redises.zpopmax('does-not-exist', count)).to eq([])
    end

    it 'returns the highest ranked elements' do
      expect(@redises.zpopmax(@key, count)).to eq([['three', 3], ['two', 2]])
      expect(@redises.zcard(@key)).to eq(1)
    end
  end

  context 'when count is greater than the size of the set' do
    let(:count) { 4 }

    it 'returns the entire set' do
      before = @redises.zrange(@key, 0, count, with_scores: true).reverse
      expect(@redises.zpopmax(@key, count)).to eq(before)
      expect(@redises.zcard(@key)).to eq(0)
    end
  end

  it_should_behave_like 'a zset-only command'
end
