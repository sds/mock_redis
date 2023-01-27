require 'spec_helper'

RSpec.describe '#hdel(key, field)' do
  before do
    @key = 'mock-redis-test:hdel'
    @redises.hset(@key, 'k1', 'v1')
    @redises.hset(@key, 'k2', 'v2')
  end

  it 'returns 1 when it removes a field' do
    expect(@redises.hdel(@key, 'k1')).to eq(1)
  end

  it 'returns 0 when it does not remove a field' do
    expect(@redises.hdel(@key, 'nonesuch')).to eq(0)
  end

  it 'actually removes the field' do
    @redises.hdel(@key, 'k1')
    expect(@redises.hget(@key, 'k1')).to be_nil
  end

  it 'treats the field as a string' do
    field = 2
    @redises.hset(@key, field, 'two')
    @redises.hdel(@key, field)
    expect(@redises.hget(@key, field)).to be_nil
  end

  it 'removes only the field specified' do
    @redises.hdel(@key, 'k1')
    expect(@redises.hget(@key, 'k2')).to eq('v2')
  end

  it 'cleans up empty hashes' do
    @redises.hdel(@key, 'k1')
    @redises.hdel(@key, 'k2')
    expect(@redises.get(@key)).to be_nil
  end

  it 'supports a variable number of arguments' do
    @redises.hdel(@key, 'k1', 'k2')
    expect(@redises.get(@key)).to be_nil
  end

  it 'treats variable arguments as strings' do
    field = 2
    @redises.hset(@key, field, 'two')
    @redises.hdel(@key, field)
    expect(@redises.hget(@key, field)).to be_nil
  end

  it 'supports a variable number of fields as array' do
    expect(@redises.hdel(@key, %w[k1 k2])).to eq(2)

    expect(@redises.hget(@key, 'k1')).to be_nil
    expect(@redises.hget(@key, 'k2')).to be_nil
    expect(@redises.get(@key)).to be_nil
  end

  it 'supports a list of fields in various way' do
    expect(@redises.hdel(@key, ['k1'], 'k2')).to eq(2)

    expect(@redises.hget(@key, 'k1')).to be_nil
    expect(@redises.hget(@key, 'k2')).to be_nil
    expect(@redises.get(@key)).to be_nil
  end

  it 'raises error if an empty array is passed' do
    expect { @redises.hdel(@key, []) }.to raise_error(
      Redis::CommandError,
      "ERR wrong number of arguments for 'hdel' command"
    )
  end

  it_should_behave_like 'a hash-only command'
end
