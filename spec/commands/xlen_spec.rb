require 'spec_helper'

describe '#xlen(key)' do
  before { @key = 'mock-redis-test:xadd' }

  it 'returns the number of items in the stream' do
    expect(@redises.xlen(@key)).to eq 0
    @redises.xadd(@key, '*', 'key', 'value')
    expect(@redises.xlen(@key)).to eq 1
    3.times { @redises.xadd(@key, '*', 'key', 'value') }
    expect(@redises.xlen(@key)).to eq 4
  end
end
