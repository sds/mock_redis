require 'spec_helper'

RSpec.describe '#linsert(key, :before|:after, pivot, value)' do
  let(:default_error) { Redis::CommandError }

  before { @key = 'mock-redis-test:48733' }

  it 'returns the new size of the list when the pivot is found' do
    @redises.lpush(@key, 'X')

    expect(@redises.linsert(@key, :before, 'X', 'Y')).to eq(2)
    expect(@redises.lpushx(@key, 'X')).to eq(3)
  end

  it 'does nothing when run against a nonexistent key' do
    expect(@redises.linsert(@key, :before, 1, 2)).to eq(0)
    expect(@redises.get(@key)).to be_nil
  end

  it 'returns -1 if the pivot is not found' do
    @redises.lpush(@key, 1)
    expect(@redises.linsert(@key, :after, 'X', 'Y')).to eq(-1)
  end

  it 'inserts elements before the pivot when given :before as position' do
    @redises.lpush(@key, 'bert')
    @redises.linsert(@key, :before, 'bert', 'ernie')

    expect(@redises.lindex(@key, 0)).to eq('ernie')
    expect(@redises.lindex(@key, 1)).to eq('bert')
  end

  it "inserts elements before the pivot when given 'before' as position" do
    @redises.lpush(@key, 'bert')
    @redises.linsert(@key, 'before', 'bert', 'ernie')

    expect(@redises.lindex(@key, 0)).to eq('ernie')
    expect(@redises.lindex(@key, 1)).to eq('bert')
  end

  it 'inserts elements after the pivot when given :after as position' do
    @redises.lpush(@key, 'bert')
    @redises.linsert(@key, :after, 'bert', 'ernie')

    expect(@redises.lindex(@key, 0)).to eq('bert')
    expect(@redises.lindex(@key, 1)).to eq('ernie')
  end

  it "inserts elements after the pivot when given 'after' as position" do
    @redises.lpush(@key, 'bert')
    @redises.linsert(@key, 'after', 'bert', 'ernie')

    expect(@redises.lindex(@key, 0)).to eq('bert')
    expect(@redises.lindex(@key, 1)).to eq('ernie')
  end

  it 'raises an error when given a position that is neither before nor after' do
    expect do
      @redises.linsert(@key, :near, 1, 2)
    end.to raise_error(Redis::CommandError)
  end

  it 'stores values as strings' do
    @redises.lpush(@key, 1)
    @redises.linsert(@key, :before, 1, 2)
    expect(@redises.lindex(@key, 0)).to eq('2')
  end

  it_should_behave_like 'a list-only command'
end
