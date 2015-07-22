require 'spec_helper'

describe '#hmset(key, field, value [, field, value ...])' do
  before do
    @key = 'mock-redis-test:hmset'
  end

  it "returns 'OK'" do
    @redises.hmset(@key, 'k1', 'v1', 'k2', 'v2').should == 'OK'
  end

  it 'sets the values' do
    @redises.hmset(@key, 'k1', 'v1', 'k2', 'v2')
    @redises.hmget(@key, 'k1', 'k2').should == %w[v1 v2]
  end

  it 'updates an existing hash' do
    @redises.hset(@key, 'foo', 'bar')
    @redises.hmset(@key, 'bert', 'ernie', 'diet', 'coke')

    @redises.hmget(@key, 'foo', 'bert', 'diet').
      should == %w[bar ernie coke]
  end

  it 'stores the values as strings' do
    @redises.hmset(@key, 'one', 1)
    @redises.hget(@key, 'one').should == '1'
  end

  it 'raises an error if given no fields or values' do
    lambda do
      @redises.hmset(@key)
    end.should raise_error(Redis::CommandError)
  end

  it 'raises an error if given an odd number of fields+values' do
    lambda do
      @redises.hmset(@key, 'k1', 1, 'k2')
    end.should raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a hash-only command'
end
