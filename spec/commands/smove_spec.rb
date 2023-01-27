require 'spec_helper'

RSpec.describe '#smove(source, destination, member)' do
  before do
    @src  = 'mock-redis-test:smove-source'
    @dest = 'mock-redis-test:smove-destination'

    @redises.sadd(@src, 1)
    @redises.sadd(@dest, 2)
  end

  it 'returns true if the member exists in src' do
    expect(@redises.smove(@src, @dest, 1)).to eq(true)
  end

  it 'returns false if the member exists in src' do
    expect(@redises.smove(@src, @dest, 'nope')).to eq(false)
  end

  it 'returns true if the member exists in src and dest' do
    @redises.sadd(@dest, 1)
    expect(@redises.smove(@src, @dest, 1)).to eq(true)
  end

  it 'moves member from source to destination' do
    @redises.smove(@src, @dest, 1)
    expect(@redises.sismember(@dest, 1)).to eq(true)
    expect(@redises.sismember(@src, 1)).to eq(false)
  end

  it 'cleans up empty sets' do
    @redises.smove(@src, @dest, 1)
    expect(@redises.get(@src)).to be_nil
  end

  it 'treats a nonexistent value as an empty set' do
    expect(@redises.smove('mock-redis-test:nonesuch', @dest, 1)).to eq(false)
  end

  it_should_behave_like 'a set-only command'
end
