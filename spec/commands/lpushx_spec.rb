require 'spec_helper'

RSpec.describe '#lpushx(key, value)' do
  before { @key = 'mock-redis-test:81267' }

  it 'returns the new size of the list' do
    @redises.lpush(@key, 'X')

    expect(@redises.lpushx(@key, 'X')).to eq(2)
    expect(@redises.lpushx(@key, 'X')).to eq(3)
  end

  it 'does nothing when run against a nonexistent key' do
    @redises.lpushx(@key, 'value')
    expect(@redises.get(@key)).to be_nil
  end

  it 'prepends items to the list' do
    @redises.lpush(@key, 'bert')
    @redises.lpushx(@key, 'ernie')

    expect(@redises.lindex(@key, 0)).to eq('ernie')
    expect(@redises.lindex(@key, 1)).to eq('bert')
  end

  it 'stores values as strings' do
    @redises.lpush(@key, 1)
    @redises.lpushx(@key, 2)
    expect(@redises.lindex(@key, 0)).to eq('2')
  end

  it 'raises an error if an empty array is given' do
    @redises.lpush(@key, 'X')
    expect do
      @redises.lpushx(@key, [])
    end.to raise_error(Redis::CommandError)
  end

  it 'stores multiple items if an array of more than one item is given' do
    @redises.lpush(@key, 'X')
    expect(@redises.lpushx(@key, [1, 2])).to eq(3)
    expect(@redises.lrange(@key, 0, -1)).to eq(%w[2 1 X])
  end

  it_should_behave_like 'a list-only command'
end
