require 'spec_helper'

RSpec.describe '#zscore(key, member)' do
  before { @key = 'mock-redis-test:zscore' }

  it 'returns the score as a string' do
    expect(@redises.zadd(@key, 0.25, 'foo')).to eq(true)
    expect(@redises.zscore(@key, 'foo')).to eq(0.25)
  end

  it 'handles integer members correctly' do
    member = 11
    expect(@redises.zadd(@key, 0.25, member)).to eq(true)
    expect(@redises.zscore(@key, member)).to eq(0.25)
  end

  it 'returns nil if member is not present in the set' do
    expect(@redises.zscore(@key, 'foo')).to be_nil
  end

  it_should_behave_like 'a zset-only command'
end
