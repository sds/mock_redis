require 'spec_helper'

RSpec.describe '#rpush(key)' do
  before { @key = "mock-redis-test:#{__FILE__}" }

  it 'returns the new size of the list' do
    expect(@redises.rpush(@key, 'X')).to eq(1)
    expect(@redises.rpush(@key, 'X')).to eq(2)
  end

  it 'creates a new list when run against a nonexistent key' do
    @redises.rpush(@key, 'value')
    expect(@redises.llen(@key)).to eq(1)
  end

  it 'appends items to the list' do
    @redises.rpush(@key, 'bert')
    @redises.rpush(@key, 'ernie')

    expect(@redises.lindex(@key, 0)).to eq('bert')
    expect(@redises.lindex(@key, 1)).to eq('ernie')
  end

  it 'stores values as strings' do
    @redises.rpush(@key, 1)
    expect(@redises.lindex(@key, 0)).to eq('1')
  end

  it 'supports a variable number of arguments' do
    expect(@redises.rpush(@key, [1, 2, 3])).to eq(3)
    expect(@redises.lindex(@key, 0)).to eq('1')
    expect(@redises.lindex(@key, 1)).to eq('2')
    expect(@redises.lindex(@key, 2)).to eq('3')
  end

  it 'raises an error if an empty array is given' do
    expect do
      @redises.rpush(@key, [])
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a list-only command'
end
