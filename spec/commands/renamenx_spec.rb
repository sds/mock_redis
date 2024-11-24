require 'spec_helper'

RSpec.describe '#renamenx(key, newkey)' do
  before do
    @key = 'mock-redis-test:renamenx:key'
    @newkey = 'mock-redis-test:renamenx:newkey'

    @redises.set(@key, 'oof')
  end

  it 'responds with true when newkey does not exist' do
    expect(@redises.renamenx(@key, @newkey)).to eq(true)
  end

  it 'responds with false when newkey exists' do
    @redises.set(@newkey, 'monkey')
    expect(@redises.renamenx(@key, @newkey)).to eq(false)
  end

  it 'moves the data' do
    @redises.renamenx(@key, @newkey)
    expect(@redises.get(@newkey)).to eq('oof')
  end

  it 'raises an error when the source key is nonexistant' do
    @redises.del(@key)
    expect do
      @redises.renamenx(@key, @newkey)
    end.to raise_error(Redis::CommandError)
  end

  it 'returns false when key == newkey' do
    expect(@redises.renamenx(@key, @key)).to eq(false)
  end

  it 'leaves any existing value at newkey alone' do
    @redises.set(@newkey, 'rab')
    @redises.renamenx(@key, @newkey)
    expect(@redises.get(@newkey)).to eq('rab')
  end
end
