require 'spec_helper'

RSpec.describe '#bzmpop(*keys)', redis: 7.0 do
  before do
    @zset1 = 'mock-redis-test:bzmpop-zset'
    @zset2 = 'mock-redis-test:bzmpop-zset2'

    @redises.zadd(@zset1, 1, 'one')
    @redises.zadd(@zset1, 2, 'two')
    @redises.zadd(@zset1, 3, 'three')

    @redises.zadd(@zset2, 10, 'ten')
    @redises.zadd(@zset2, 11, 'eleven')
    @redises.zadd(@zset2, 12, 'twelve')
  end

  it 'returns and removes the lowest scored element of the first non-empty zset' do
    expect(@redises.bzmpop(1, 'empty', @zset1, @zset2)).to eq([@zset1, [['one', 1.0]]])

    expect(@redises.zrange(@zset1, 0, -1, with_scores: true))
      .to eq([['two', 2.0], ['three', 3.0]])

    expect(@redises.zrange(@zset2, 0, -1, with_scores: true))
      .to eq([['ten', 10.0], ['eleven', 11.0], ['twelve', 12.0]])
  end

  it 'returns and removes the lowest scored element when modifier is MIN' do
    expect(@redises.bzmpop(1, 'empty', @zset1, @zset2, modifier: 'MIN'))
      .to eq([@zset1, [['one', 1.0]]])

    expect(@redises.zrange(@zset1, 0, -1, with_scores: true))
      .to eq([['two', 2.0], ['three', 3.0]])

    expect(@redises.zrange(@zset2, 0, -1, with_scores: true))
      .to eq([['ten', 10.0], ['eleven', 11.0], ['twelve', 12.0]])
  end

  it 'returns and removes the highest scored element when modifier is MAX' do
    expect(@redises.bzmpop(1, 'empty', @zset1, @zset2, modifier: 'MAX'))
      .to eq([@zset1, [['three', 3.0]]])

    expect(@redises.zrange(@zset1, 0, -1, with_scores: true))
      .to eq([['one', 1.0], ['two', 2.0]])

    expect(@redises.zrange(@zset2, 0, -1, with_scores: true))
      .to eq([['ten', 10.0], ['eleven', 11.0], ['twelve', 12.0]])
  end

  it 'returns and removes multiple elements from the min when count is given' do
    expect(@redises.bzmpop(1, 'empty', @zset1, @zset2, count: 2))
      .to eq([@zset1, [['one', 1.0], ['two', 2.0]]])

    expect(@redises.zrange(@zset1, 0, -1, with_scores: true))
      .to eq([['three', 3.0]])

    expect(@redises.zrange(@zset2, 0, -1, with_scores: true))
      .to eq([['ten', 10.0], ['eleven', 11.0], ['twelve', 12.0]])
  end

  it 'returns and removes multiple elements from the max when count given and modifier is MAX' do
    expect(@redises.bzmpop(1, 'empty', @zset1, @zset2, count: 2, modifier: 'MAX')).to(
      eq([@zset1, [['three', 3.0], ['two', 2.0]]])
    )

    expect(@redises.zrange(@zset1, 0, -1, with_scores: true))
      .to eq([['one', 1.0]])

    expect(@redises.zrange(@zset2, 0, -1, with_scores: true))
      .to eq([['ten', 10.0], ['eleven', 11.0], ['twelve', 12.0]])
  end

  it 'raises an error for non-zset source value' do
    @redises.set(@zset1, 'string value')

    expect do
      @redises.bzmpop(1, @zset1, @zset2)
    end.to raise_error(Redis::WrongTypeError)
  end

  it 'raises an error for invalid modifier' do
    expect do
      @redises.bzmpop(1, @zset1, modifier: 'INVALID')
    end.to raise_error(ArgumentError)
  end

  it 'raises an error on negative timeout' do
    expect do
      @redises.bzmpop(-1, @zset1, @zset2)
    end.to raise_error(ArgumentError)
  end

  it 'raises an error for non-zset values in the key list' do
    @redises.set('string-key', 'value')

    expect do
      @redises.bzmpop(1, 'string-key')
    end.to raise_error(Redis::WrongTypeError)
  end

  context '[mock only]' do
    it 'ignores positive timeouts and returns nil when all zsets are empty' do
      expect(@redises.mock.bzmpop(1, 'empty')).to be_nil
    end

    it 'raises WouldBlock on zero timeout when all zsets are empty' do
      expect do
        @redises.mock.bzmpop(0, 'empty')
      end.to raise_error(MockRedis::WouldBlock)
    end
  end
end
