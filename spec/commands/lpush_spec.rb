require 'spec_helper'

RSpec.describe '#lpush(key, value)' do
  before { @key = 'mock-redis-test:57367' }

  it 'returns the new size of the list' do
    expect(@redises.lpush(@key, 'X')).to eq(1)
    expect(@redises.lpush(@key, 'X')).to eq(2)
  end

  it 'creates a new list when run against a nonexistent key' do
    @redises.lpush(@key, 'value')
    expect(@redises.llen(@key)).to eq(1)
  end

  it 'prepends items to the list' do
    @redises.lpush(@key, 'bert')
    @redises.lpush(@key, 'ernie')

    expect(@redises.lindex(@key, 0)).to eq('ernie')
    expect(@redises.lindex(@key, 1)).to eq('bert')
  end

  it 'stores values as strings' do
    @redises.lpush(@key, 1)
    expect(@redises.lindex(@key, 0)).to eq('1')
  end

  it 'supports a variable number of arguments' do
    expect(@redises.lpush(@key, [1, 2, 3])).to eq(3)
    expect(@redises.lindex(@key, 0)).to eq('3')
    expect(@redises.lindex(@key, 1)).to eq('2')
    expect(@redises.lindex(@key, 2)).to eq('1')
  end

  it 'raises an error if an empty array is given' do
    expect do
      @redises.lpush(@key, [])
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a list-only command'
end
