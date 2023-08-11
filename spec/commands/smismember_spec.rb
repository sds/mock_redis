require 'spec_helper'

RSpec.describe '#smismember(key, *members)' do
  before do
    @key = 'mock-redis-test:smismember'
    @redises.sadd(@key, 'whiskey')
    @redises.sadd(@key, 'beer')
  end

  it 'returns true if member is in set' do
    expect(@redises.smismember(@key, 'whiskey')).to eq([true])
    expect(@redises.smismember(@key, 'beer')).to eq([true])
    expect(@redises.smismember(@key, 'whiskey', 'beer')).to eq([true, true])
    expect(@redises.smismember(@key, %w[whiskey beer])).to eq([true, true])
  end

  it 'returns false if member is not in set' do
    expect(@redises.smismember(@key, 'cola')).to eq([false])
    expect(@redises.smismember(@key, 'whiskey', 'cola')).to eq([true, false])
    expect(@redises.smismember(@key, %w[whiskey beer cola])).to eq([true, true, false])
  end

  it 'stringifies member' do
    @redises.sadd(@key, '1')
    expect(@redises.smismember(@key, 1)).to eq([true])
    expect(@redises.smismember(@key, [1])).to eq([true])
  end

  it 'treats a nonexistent value as an empty set' do
    expect(@redises.smismember('mock-redis-test:nonesuch', 'beer')).to eq([false])
  end

  it_should_behave_like 'a set-only command'
end
