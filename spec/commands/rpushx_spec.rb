require 'spec_helper'

RSpec.describe '#rpushx(key, value)' do
  before { @key = 'mock-redis-test:92925' }

  it 'returns the new size of the list' do
    @redises.lpush(@key, 'X')

    expect(@redises.rpushx(@key, 'X')).to eq(2)
    expect(@redises.rpushx(@key, 'X')).to eq(3)
  end

  it 'does nothing when run against a nonexistent key' do
    @redises.rpushx(@key, 'value')
    expect(@redises.get(@key)).to be_nil
  end

  it 'appends items to the list' do
    @redises.lpush(@key, 'bert')
    @redises.rpushx(@key, 'ernie')

    expect(@redises.lindex(@key, 0)).to eq('bert')
    expect(@redises.lindex(@key, 1)).to eq('ernie')
  end

  it 'stores values as strings' do
    @redises.rpush(@key, 1)
    @redises.rpushx(@key, 2)
    expect(@redises.lindex(@key, 1)).to eq('2')
  end

  it 'raises an error if an empty array is given' do
    @redises.lpush(@key, 'X')
    expect do
      @redises.rpushx(@key, [])
    end.to raise_error(Redis::CommandError)
  end

  it 'stores multiple items if an array of more than one item is given' do
    @redises.lpush(@key, 'X')
    expect(@redises.rpushx(@key, [1, 2])).to eq(3)
    expect(@redises.lrange(@key, 0, -1)).to eq(%w[X 1 2])
  end

  it_should_behave_like 'a list-only command'
end
