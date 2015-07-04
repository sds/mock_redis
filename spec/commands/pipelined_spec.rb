require 'spec_helper'

describe '#pipelined' do
  it 'yields to its block' do
    res = false
    @redises.pipelined do
      res = true
    end
    res.should == true
  end

  context 'with a few added data' do
    let(:key1)   { 'hello' }
    let(:key2)   { 'world' }
    let(:value1) { 'foo' }
    let(:value2) { 'bar' }

    before do
      @redises.set key1, value1
      @redises.set key2, value2
    end

    it 'returns results of pipelined operations' do
      results = @redises.pipelined do |redis|
        redis.get key1
        redis.get key2
      end

      results.should == [value1, value2]
    end

    it 'returns futures' do
      future = nil

      @redises.mock.pipelined do |redis|
        future = redis.get key1
      end

      future.class.should be MockRedis::Future
    end
  end
end
