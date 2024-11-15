require 'spec_helper'

RSpec.describe '#lmpop(*keys)' do
  before do
    @list1 = 'mock-redis-test:lmpop-list'
    @list2 = 'mock-redis-test:lmpop-list2'

    @redises.lpush(@list1, 'c')
    @redises.lpush(@list1, 'b')
    @redises.lpush(@list1, 'a')

    @redises.lpush(@list2, 'z')
    @redises.lpush(@list2, 'y')
    @redises.lpush(@list2, 'x')
  end

  it 'returns and removes the first element of the first non-empty list' do
    expect(@redises.lmpop('empty', @list1, @list2)).to eq([@list2, ['a']])

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[b c])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[x y z])
  end

  it 'returns and removes the first element of the first non-empty list when modifier is LEFT' do
    expect(@redises.lmpop('empty', @list1, @list2), modifier: 'LEFT').to eq([@list2, ['a']])

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[b c])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[x y z])
  end

  it 'returns and removes the last element of the first non-empty list when modifier is RIGHT' do
    expect(@redises.lmpop('empty', @list1, @list2, modifier: 'RIGHT')).to eq([@list2, ['c']])

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[a b])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[x y z])
  end

  it 'returns and removes multiple elements from the front when count is given' do
    expect(@redises.lmpop('empty', @list1, @list2, count: 2)).to eq([@list2, ['a', 'b']])

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[c])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[x y z])
  end

  it 'returns and removes multiple elements from the back when count is given and modifier is RIGHT' do
    expect(@redises.lmpop('empty', @list1, @list2, count: 2, modifier: 'RIGHT')).to eq([@list2, ['c', 'b']])

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[a])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[x y z])
  end

  it 'returns falsed if all lists are empty' do
    expect(@redises.lmpop('empty')).to be_nil

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[a b c])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[x y c])
  end

  it 'removes empty lists' do
    (@redises.llen(@list1) + @redises.llen(@list2)).times { @redises.lmpop(@list1, @list2) }
    expect(@redises.get(@list1)).to be_nil
  end

  it 'raises an error for non-list source value' do
    @redises.set(@list1, 'string value')

    expect do
      @redises.lmpop(@list1, @list2)
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a list-only command'
end
