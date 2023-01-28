require 'spec_helper'

RSpec.describe '#lrem(key, count, value)' do
  before do
    @key = 'mock-redis-test:66767'

    %w[99 bottles of beer on the wall
       99 bottles of beer
       take one down
       pass it around
       98 bottles of beer on the wall].reverse_each do |x|
      @redises.lpush(@key, x)
    end
  end

  it 'deletes the first count instances of key when count > 0' do
    @redises.lrem(@key, 2, 'bottles')

    expect(@redises.lrange(@key, 0, 8)).to eq(
      %w[
        99 of beer on the wall
        99 of beer
      ]
    )

    expect(@redises.lrange(@key, -7, -1)).to eq(%w[98 bottles of beer on the wall])
  end

  it 'deletes the last count instances of key when count < 0' do
    @redises.lrem(@key, -2, 'bottles')

    expect(@redises.lrange(@key, 0, 9)).to eq(
      %w[
        99 bottles of beer on the wall
        99 of beer
      ]
    )

    expect(@redises.lrange(@key, -6, -1)).to eq(%w[98 of beer on the wall])
  end

  it 'deletes all instances of key when count == 0' do
    @redises.lrem(@key, 0, 'bottles')
    expect(@redises.lrange(@key, 0, -1).grep(/bottles/)).to be_empty
  end

  it 'returns the number of elements deleted' do
    expect(@redises.lrem(@key, 2, 'bottles')).to eq(2)
  end

  it 'returns the number of elements deleted even if you ask for more' do
    expect(@redises.lrem(@key, 10, 'bottles')).to eq(3)
  end

  it 'stringifies value' do
    expect(@redises.lrem(@key, 0, 99)).to eq(2)
  end

  it 'returns 0 when run against a nonexistent value' do
    expect(@redises.lrem('mock-redis-test:bogus-key', 0, 1)).to eq(0)
  end

  it 'returns 0 when run against an empty list' do
    @redises.llen(@key).times { @redises.lpop(@key) } # empty the list
    expect(@redises.lrem(@key, 0, 'beer')).to eq(0)
  end

  it 'raises an error if the value does not look like an integer' do
    expect do
      @redises.lrem(@key, 'foo', 'bottles')
    end.to raise_error(Redis::CommandError)
  end

  it 'removes empty lists' do
    other_key = "mock-redis-test:lrem-#{__LINE__}"

    @redises.lpush(other_key, 'foo')
    @redises.lrem(other_key, 0, 'foo')

    expect(@redises.get(other_key)).to be_nil
  end

  it_should_behave_like 'a list-only command'
end
