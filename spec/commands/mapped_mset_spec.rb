require 'spec_helper'

RSpec.describe '#mapped_mset(hash)' do
  before do
    @key1 = 'mock-redis-test:a'
    @key2 = 'mock-redis-test:b'
    @key3 = 'mock-redis-test:c'

    @redises.set(@key1, '1')
    @redises.set(@key2, '2')
  end

  it 'sets the values properly' do
    expect(@redises.mapped_mset(@key1 => 'one', @key3 => 'three')).to eq('OK')
    expect(@redises.get(@key1)).to eq('one')
    expect(@redises.get(@key2)).to eq('2') # left alone
    expect(@redises.get(@key3)).to eq('three')
  end
end
