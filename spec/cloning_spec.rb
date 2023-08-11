require 'spec_helper'

RSpec.describe 'MockRedis#clone' do
  before do
    @mock = MockRedis.new
  end

  context 'the stored data' do
    before do
      @mock.set('foo', 'bar')
      @mock.hset('foohash', 'bar', 'baz')
      @mock.lpush('foolist', 'bar')
      @mock.sadd('fooset', 'bar')
      @mock.zadd('foozset', 1, 'bar')

      @clone = @mock.clone
    end

    it 'copies the stored data to the clone' do
      expect(@clone.get('foo')).to eq('bar')
    end

    it 'performs a deep copy (string values)' do
      @mock.del('foo')
      expect(@clone.get('foo')).to eq('bar')
    end

    it 'performs a deep copy (list values)' do
      @mock.lpop('foolist')
      expect(@clone.lrange('foolist', 0, 1)).to eq(['bar'])
    end

    it 'performs a deep copy (hash values)' do
      @mock.hset('foohash', 'bar', 'quux')
      expect(@clone.hgetall('foohash')).to eq({ 'bar' => 'baz' })
    end

    it 'performs a deep copy (set values)' do
      @mock.srem('fooset', 'bar')
      expect(@clone.smembers('fooset')).to eq(['bar'])
    end

    it 'performs a deep copy (zset values)' do
      @mock.zadd('foozset', 2, 'bar')
      expect(@clone.zscore('foozset', 'bar')).to eq(1.0)
    end
  end

  context 'expiration times' do
    before do
      @mock.set('foo', 1)
      @mock.expire('foo', 60_026)

      @clone = @mock.clone
    end

    it 'copies the expiration times' do
      expect(@clone.ttl('foo')).to be > 0
    end

    it 'deep-copies the expiration times' do
      @mock.persist('foo')
      expect(@clone.ttl('foo')).to be > 0
    end

    it 'deep-copies the expiration times' do
      @clone.persist('foo')
      expect(@mock.ttl('foo')).to be > 0
    end
  end

  context 'transactional info' do
    before do
      @mock.multi
      @mock.incr('foo')
      @mock.incrby('foo', 2)
      @mock.incrby('foo', 4)

      @clone = @mock.clone
    end

    it 'makes sure the clone is in a transaction' do
      expect do
        @clone.exec
      end.not_to raise_error
    end

    it 'deep-copies the queued commands' do
      @clone.incrby('foo', 8)
      expect(@clone.exec).to eq([1, 3, 7, 15])

      expect(@mock.exec).to eq([1, 3, 7])
    end
  end
end
