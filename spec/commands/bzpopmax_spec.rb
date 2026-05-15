require 'spec_helper'

RSpec.describe '#bzpopmax(key [, key, ...,], timeout)' do
  before do
    @zset1 = 'mock-redis-test:bzpopmax1'
    @zset2 = 'mock-redis-test:bzpopmax2'

    @redises.zadd(@zset1, 1, 'one')
    @redises.zadd(@zset1, 2, 'two')
    @redises.zadd(@zset2, 10, 'ten')
    @redises.zadd(@zset2, 11, 'eleven')
  end

  it 'returns [first-nonempty-zset, popped-member, score]' do
    expect(@redises.bzpopmax(@zset1, @zset2)).to eq([@zset1, 'two', 2.0])
  end

  it 'pops that value off the sorted set' do
    @redises.bzpopmax(@zset1, @zset2)
    @redises.bzpopmax(@zset1, @zset2)

    expect(@redises.bzpopmax(@zset1, @zset2)).to eq([@zset2, 'eleven', 11.0])
  end

  it 'ignores empty keys' do
    expect(@redises.bzpopmax('mock-redis-test:not-here', @zset1)).to eq(
      [@zset1, 'two', 2.0]
    )
  end

  it 'raises an error on negative timeout' do
    expect do
      @redises.bzpopmax(@zset1, @zset2, :timeout => -1)
    end.to raise_error(ArgumentError)
  end

  it_should_behave_like 'a zset-only command'

  context '[mock only]' do
    it 'ignores positive timeouts and returns nil' do
      expect(@redises.mock.bzpopmax('mock-redis-test:not-here', :timeout => 1)).to be_nil
    end

    it 'ignores positive legacy timeouts and returns nil' do
      expect(@redises.mock.bzpopmax('mock-redis-test:not-here', 1)).to be_nil
    end

    it 'raises WouldBlock on zero timeout (no blocking in the mock)' do
      expect do
        @redises.mock.bzpopmax('mock-redis-test:not-here', :timeout => 0)
      end.to raise_error(MockRedis::WouldBlock)
    end
  end
end
