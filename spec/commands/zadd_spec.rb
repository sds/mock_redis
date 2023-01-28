require 'spec_helper'

RSpec.describe '#zadd(key, score, member)' do
  before { @key = 'mock-redis-test:zadd' }

  it "returns true if member wasn't present in the set" do
    expect(@redises.zadd(@key, 1, 'foo')).to eq(true)
  end

  it 'returns false if member was present in the set' do
    @redises.zadd(@key, 1, 'foo')
    expect(@redises.zadd(@key, 1, 'foo')).to eq(false)
  end

  it 'adds member to the set' do
    @redises.zadd(@key, 1, 'foo')
    expect(@redises.zrange(@key, 0, -1)).to eq(['foo'])
  end

  it 'treats integer members as strings' do
    member = 11
    @redises.zadd(@key, 1, member)
    expect(@redises.zrange(@key, 0, -1)).to eq([member.to_s])
  end

  it 'allows scores to be set to Float::INFINITY' do
    member = '1'
    @redises.zadd(@key, Float::INFINITY, member)
    expect(@redises.zrange(@key, 0, -1)).to eq([member])
  end

  it 'updates the score' do
    @redises.zadd(@key, 1, 'foo')
    @redises.zadd(@key, 2, 'foo')

    expect(@redises.zscore(@key, 'foo')).to eq(2.0)
  end

  it 'with XX option command do nothing if element not exist' do
    @redises.zadd(@key, 1, 'foo')
    @redises.zadd(@key, 2, 'bar', xx: true)
    expect(@redises.zrange(@key, 0, -1)).not_to include 'bar'
  end

  it 'with XX option command update index on exist element' do
    @redises.zadd(@key, 1, 'foo')
    @redises.zadd(@key, 2, 'foo', xx: true)
    expect(@redises.zscore(@key, 'foo')).to eq(2.0)
  end

  it 'with XX option and multiple elements command update index on exist element' do
    @redises.zadd(@key, 1, 'foo')
    added_count = @redises.zadd(@key, [[2, 'foo'], [2, 'bar']], xx: true)
    expect(added_count).to eq(0)

    expect(@redises.zscore(@key, 'foo')).to eq(2.0)
    expect(@redises.zrange(@key, 0, -1)).not_to include 'bar'
  end

  it "with NX option don't update current element" do
    @redises.zadd(@key, 1, 'foo')
    @redises.zadd(@key, 2, 'foo', nx: true)
    expect(@redises.zscore(@key, 'foo')).to eq(1.0)
  end

  it 'with NX option create new element' do
    @redises.zadd(@key, 1, 'foo')
    @redises.zadd(@key, 2, 'bar', nx: true)
    expect(@redises.zrange(@key, 0, -1)).to include 'bar'
  end

  it 'with NX option and multiple elements command only create element' do
    @redises.zadd(@key, 1, 'foo')
    added_count = @redises.zadd(@key, [[2, 'foo'], [2, 'bar']], nx: true)
    expect(added_count).to eq(1)
    expect(@redises.zscore(@key, 'bar')).to eq(2.0)
    expect(@redises.zrange(@key, 0, -1)).to eq %w[foo bar]
  end

  it 'XX and NX options in same time raise error' do
    expect do
      @redises.zadd(@key, 1, 'foo', nx: true, xx: true)
    end.to raise_error(Redis::CommandError)
  end

  it 'with INCR is act like zincrby' do
    expect(@redises.zadd(@key, 10, 'bert', incr: true)).to eq(10.0)
    expect(@redises.zadd(@key, 3, 'bert', incr: true)).to eq(13.0)
  end

  it 'with INCR and XX not create element' do
    expect(@redises.zadd(@key, 10, 'bert', xx: true, incr: true)).to be_nil
  end

  it 'with INCR and XX increase score for exist element' do
    @redises.zadd(@key, 2, 'bert')
    expect(@redises.zadd(@key, 10, 'bert', xx: true, incr: true)).to eq(12.0)
  end

  it 'with INCR and NX create element with score' do
    expect(@redises.zadd(@key, 11, 'bert', nx: true, incr: true)).to eq(11.0)
  end

  it 'with INCR and NX not update element' do
    @redises.zadd(@key, 1, 'bert')
    expect(@redises.zadd(@key, 10, 'bert', nx: true, incr: true)).to be_nil
  end

  it 'with INCR with variable number of arguments raise error' do
    expect do
      @redises.zadd(@key, [[1, 'one'], [2, 'two']], incr: true)
    end.to raise_error(Redis::CommandError)
  end

  it 'supports a variable number of arguments' do
    @redises.zadd(@key, [[1, 'one'], [2, 'two']])
    @redises.zadd(@key, [[3, 'three']])
    expect(@redises.zrange(@key, 0, -1)).to eq(%w[one two three])
  end

  it 'raises an error if an empty array is given' do
    expect do
      @redises.zadd(@key, [])
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'arg 1 is a score'
  it_should_behave_like 'a zset-only command'
end
