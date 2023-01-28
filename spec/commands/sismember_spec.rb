require 'spec_helper'

RSpec.describe '#sismember(key, member)' do
  before do
    @key = 'mock-redis-test:sismember'
    @redises.sadd(@key, 'whiskey')
    @redises.sadd(@key, 'beer')
  end

  it 'returns true if member is in set' do
    expect(@redises.sismember(@key, 'whiskey')).to eq(true)
    expect(@redises.sismember(@key, 'beer')).to eq(true)
  end

  it 'returns false if member is not in set' do
    expect(@redises.sismember(@key, 'cola')).to eq(false)
  end

  it 'stringifies member' do
    @redises.sadd(@key, '1')
    expect(@redises.sismember(@key, 1)).to eq(true)
  end

  it 'treats a nonexistent value as an empty set' do
    expect(@redises.sismember('mock-redis-test:nonesuch', 'beer')).to eq(false)
  end

  it_should_behave_like 'a set-only command'
end
