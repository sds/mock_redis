require 'spec_helper'

RSpec.describe '#mapped_msetnx(hash)' do
  before do
    @key1 = 'mock-redis-test:a'
    @key2 = 'mock-redis-test:b'
    @key3 = 'mock-redis-test:c'

    @redises.set(@key1, '1')
    @redises.set(@key2, '2')
  end

  it 'sets properly when none collide' do
    expect(@redises.mapped_msetnx(@key3 => 'three')).to eq(true)
    expect(@redises.get(@key1)).to eq('1') # existed; untouched
    expect(@redises.get(@key2)).to eq('2') # existed; untouched
    expect(@redises.get(@key3)).to eq('three')
  end

  it 'does not set any when any collide' do
    expect(@redises.mapped_msetnx(@key1 => 'one', @key3 => 'three')).to eq(false)
    expect(@redises.get(@key1)).to eq('1') # existed; untouched
    expect(@redises.get(@key2)).to eq('2') # existed; untouched
    expect(@redises.get(@key3)).to be_nil
  end
end
