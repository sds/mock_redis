require 'spec_helper'

describe "MockRedis#clone" do
  before do
    @mock = MockRedis.new
  end

  context "the stored data" do
    before do
      @mock.set('foo', 'bar')
      @mock.hset('foohash', 'bar', 'baz')
      @mock.lpush('foolist', 'bar')
      @mock.sadd('fooset', 'bar')

      @clone = @mock.clone
    end

    it "copies the stored data to the clone" do
      @clone.get('foo').should == 'bar'
    end

    it "performs a deep copy (string values)" do
      @mock.del('foo')
      @clone.get('foo').should == 'bar'
    end

    it "performs a deep copy (list values)" do
      @mock.lpop('foolist')
      @clone.lrange('foolist', 0, 1).should == ['bar']
    end

    it "performs a deep copy (hash values)" do
      @mock.hset('foohash', 'bar', 'quux')
      @clone.hgetall('foohash').should == {'bar' => 'baz'}
    end

    it "performs a deep copy (set values)" do
      @mock.srem('fooset', 'bar')
      @clone.smembers('fooset').should == ['bar']
    end

    it "performs a deep copy (zset values)" do
      pending "don't have zset operations yet"
    end
  end

  
end
