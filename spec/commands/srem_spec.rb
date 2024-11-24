require 'spec_helper'

RSpec.describe '#srem(key, member)' do
  before do
    @key = 'mock-redis-test:srem'

    @redises.sadd(@key, 'bert')
    @redises.sadd(@key, 'ernie')
  end

  it 'returns true if member is in the set' do
    expect(@redises.srem(@key, 'bert')).to eq(1)
  end

  it 'returns false if member is not in the set' do
    expect(@redises.srem(@key, 'cookiemonster')).to eq(0)
  end

  it 'removes member from the set' do
    @redises.srem(@key, 'ernie')
    expect(@redises.smembers(@key)).to eq(['bert'])
  end

  it 'stringifies member' do
    @redises.sadd(@key, '1')
    expect(@redises.srem(@key, 1)).to eq(1)
  end

  it 'cleans up empty sets' do
    @redises.smembers(@key).each { |m| @redises.srem(@key, m) }
    expect(@redises.get(@key)).to be_nil
  end

  it 'supports a variable number of arguments' do
    expect(@redises.srem(@key, %w[bert ernie])).to eq(2)
    expect(@redises.get(@key)).to be_nil
  end

  it 'allow passing an array of integers as argument' do
    @redises.sadd(@key, %w[1 2])
    expect(@redises.srem(@key, [1, 2])).to eq(2)
  end

  context 'srem?' do
    it 'returns true if member is in the set' do
      expect(@redises.srem?(@key, 'bert')).to eq(true)
    end

    it 'returns false if member is not in the set' do
      expect(@redises.srem?(@key, 'cookiemonster')).to eq(false)
    end

    it 'removes member from the set' do
      @redises.srem?(@key, 'ernie')
      expect(@redises.smembers(@key)).to eq(['bert'])
    end
  end

  it_should_behave_like 'a set-only command'
end
