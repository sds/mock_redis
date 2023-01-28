require 'spec_helper'

RSpec.describe '#hmset(key, field, value [, field, value ...])' do
  before do
    @key = 'mock-redis-test:hmset'
  end

  it "returns 'OK'" do
    expect(@redises.hmset(@key, 'k1', 'v1', 'k2', 'v2')).to eq('OK')
  end

  it 'sets the values' do
    @redises.hmset(@key, 'k1', 'v1', 'k2', 'v2')
    expect(@redises.hmget(@key, 'k1', 'k2')).to eq(%w[v1 v2])
  end

  it 'updates an existing hash' do
    @redises.hset(@key, 'foo', 'bar')
    @redises.hmset(@key, 'bert', 'ernie', 'diet', 'coke')

    expect(@redises.hmget(@key, 'foo', 'bert', 'diet')).
      to eq(%w[bar ernie coke])
  end

  it 'stores the values as strings' do
    @redises.hmset(@key, 'one', 1)
    expect(@redises.hget(@key, 'one')).to eq('1')
  end

  it 'raises an error if given no fields or values' do
    expect do
      @redises.hmset(@key)
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if given an odd number of fields+values' do
    expect do
      @redises.hmset(@key, 'k1', 1, 'k2')
    end.to raise_error(Redis::CommandError)
  end

  # The following tests address https://github.com/sds/mock_redis/issues/170
  context 'keys are stored as strings' do
    before do
      @redises.hmset(1, :foo, :bar)
      @redises.hmset(:a_sym, :boo, :bas)
    end

    it { expect(@redises.hgetall('1')).to eq @redises.hgetall(1) }
    it { expect(@redises.hgetall('a_sym')).to eq @redises.hgetall(:a_sym) }
    it { expect(@redises.del('1')).to eq 1 }
    it { expect(@redises.del(1)).to eq 1 }
    it { expect(@redises.del('a_sym')).to eq 1 }
    it { expect(@redises.del(:a_sym)).to eq 1 }

    after do
      @redises.del(1)
      @redises.del(:a_sym)
    end
  end

  # The following tests address https://github.com/sds/mock_redis/issues/134
  context 'hmset accepts an array as its only argument' do
    it { expect(@redises.hmset([@key, :bar, :bas])).to eq 'OK' }
    it { expect { @redises.hmset([:foo, :bar]) }.to raise_error(Redis::CommandError) }
  end

  it_should_behave_like 'a hash-only command'
end
