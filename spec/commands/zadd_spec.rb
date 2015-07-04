require 'spec_helper'

describe '#zadd(key, score, member)' do
  before { @key = 'mock-redis-test:zadd' }

  it "returns true if member wasn't present in the set" do
    @redises.zadd(@key, 1, 'foo').should == true
  end

  it 'returns false if member was present in the set' do
    @redises.zadd(@key, 1, 'foo')
    @redises.zadd(@key, 1, 'foo').should == false
  end

  it 'adds member to the set' do
    @redises.zadd(@key, 1, 'foo')
    @redises.zrange(@key, 0, -1).should == ['foo']
  end

  it 'treats integer members as strings' do
    member = 11
    @redises.zadd(@key, 1, member)
    @redises.zrange(@key, 0, -1).should == [member.to_s]
  end

  it 'updates the score' do
    @redises.zadd(@key, 1, 'foo')
    @redises.zadd(@key, 2, 'foo')

    @redises.zscore(@key, 'foo').should == 2.0
  end

  it 'supports a variable number of arguments' do
    @redises.zadd(@key, [[1, 'one'], [2, 'two']])
    @redises.zadd(@key, [[3, 'three']])
    @redises.zrange(@key, 0, -1).should == %w[one two three]
  end

  it 'raises an error if an empty array is given' do
    lambda do
      @redises.zadd(@key, [])
    end.should raise_error(Redis::CommandError)
  end

  it_should_behave_like 'arg 1 is a score'
  it_should_behave_like 'a zset-only command'
end
