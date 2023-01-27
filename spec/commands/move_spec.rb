require 'spec_helper'

RSpec.describe '#move(key, db)' do
  before do
    @srcdb = 0
    @destdb = 1

    @key = 'mock-redis-test:move'
  end

  context 'when key exists in destdb' do
    before do
      @redises.set(@key, 'srcvalue')
      @redises.select(@destdb)
      @redises.set(@key, 'destvalue')
      @redises.select(@srcdb)
    end

    it 'returns false' do
      expect(@redises.move(@key, @destdb)).to eq(false)
    end

    it 'leaves destdb/key alone' do
      @redises.select(@destdb)
      expect(@redises.get(@key)).to eq('destvalue')
    end

    it 'leaves srcdb/key alone' do
      expect(@redises.get(@key)).to eq('srcvalue')
    end
  end

  context 'when key does not exist in srcdb' do
    before do
      @redises.select(@destdb)
      @redises.set(@key, 'destvalue')
      @redises.select(@srcdb)
    end

    it 'returns false' do
      expect(@redises.move(@key, @destdb)).to eq(false)
    end

    it 'leaves destdb/key alone' do
      @redises.select(@destdb)
      expect(@redises.get(@key)).to eq('destvalue')
    end
  end

  context 'when key exists in the currently-selected DB and not in db' do
    before do
      @redises.set(@key, 'value')
    end

    it 'returns true' do
      expect(@redises.move(@key, @destdb)).to eq(true)
    end
  end

  context 'on a string' do
    before do
      @redises.set(@key, 'value')
      @redises.move(@key, @destdb)
    end

    it 'removes key from srcdb' do
      expect(@redises.exists?(@key)).to eq(false)
    end

    it 'copies key to destdb' do
      @redises.select(@destdb)
      expect(@redises.get(@key)).to eq('value')
    end
  end

  context 'on a list' do
    before do
      @redises.rpush(@key, 'bert')
      @redises.rpush(@key, 'ernie')
      @redises.move(@key, @destdb)
    end

    it 'removes key from srcdb' do
      expect(@redises.exists?(@key)).to eq(false)
    end

    it 'copies key to destdb' do
      @redises.select(@destdb)
      expect(@redises.lrange(@key, 0, -1)).to eq(%w[bert ernie])
    end
  end

  context 'on a hash' do
    before do
      @redises.hset(@key, 'a', 1)
      @redises.hset(@key, 'b', 2)

      @redises.move(@key, @destdb)
    end

    it 'removes key from srcdb' do
      expect(@redises.exists?(@key)).to eq(false)
    end

    it 'copies key to destdb' do
      @redises.select(@destdb)
      expect(@redises.hgetall(@key)).to eq({ 'a' => '1', 'b' => '2' })
    end
  end

  context 'on a set' do
    before do
      @redises.sadd(@key, 'beer')
      @redises.sadd(@key, 'wine')

      @redises.move(@key, @destdb)
    end

    it 'removes key from srcdb' do
      expect(@redises.exists?(@key)).to eq(false)
    end

    it 'copies key to destdb' do
      @redises.select(@destdb)
      expect(@redises.smembers(@key)).to eq(%w[wine beer])
    end
  end

  context 'on a zset' do
    before do
      @redises.zadd(@key, 1, 'beer')
      @redises.zadd(@key, 2, 'wine')

      @redises.move(@key, @destdb)
    end

    it 'removes key from srcdb' do
      expect(@redises.exists?(@key)).to eq(false)
    end

    it 'copies key to destdb' do
      @redises.select(@destdb)
      expect(@redises.zrange(@key, 0, -1, :with_scores => true)).to eq(
        [['beer', 1.0], ['wine', 2.0]]
      )
    end
  end
end
