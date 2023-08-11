require 'spec_helper'

RSpec.describe '#mget(key [, key, ...])' do
  before do
    @key1 = 'mock-redis-test:mget1'
    @key2 = 'mock-redis-test:mget2'

    @redises.set(@key1, 1)
    @redises.set(@key2, 2)
  end

  context 'emulate param array' do
    it 'returns an array of values' do
      expect(@redises.mget([@key1, @key2])).to eq(%w[1 2])
    end

    it 'returns an array of values' do
      expect(@redises.mget([@key1, @key2])).to eq(%w[1 2])
    end

    it 'returns nil for non-string keys' do
      list = 'mock-redis-test:mget-list'

      @redises.lpush(list, 'bork bork bork')

      expect(@redises.mget([@key1, @key2, list])).to eq(['1', '2', nil])
    end
  end

  context 'emulate params strings' do
    it 'returns an array of values' do
      expect(@redises.mget(@key1, @key2)).to eq(%w[1 2])
    end

    it 'returns nil for missing keys' do
      expect(@redises.mget(@key1, 'mock-redis-test:not-found', @key2)).to eq(['1', nil, '2'])
    end

    it 'returns nil for non-string keys' do
      list = 'mock-redis-test:mget-list'

      @redises.lpush(list, 'bork bork bork')

      expect(@redises.mget(@key1, @key2, list)).to eq(['1', '2', nil])
    end

    it 'raises an error if you pass it 0 arguments' do
      expect do
        @redises.mget
      end.to raise_error(Redis::CommandError)
    end

    it 'raises an error if you pass it empty array' do
      expect do
        @redises.mget([])
      end.to raise_error(Redis::CommandError)
    end
  end

  context 'emulate block' do
    it 'returns an array of values' do
      expect(@redises.mget(@key1, @key2) { |values| values.map(&:to_i) }).to eq([1, 2])
    end
  end
end
