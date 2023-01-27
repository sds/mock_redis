require 'spec_helper'

RSpec.describe '#rename(key, newkey)' do
  before do
    @key = 'mock-redis-test:rename:key'
    @newkey = 'mock-redis-test:rename:newkey'

    @redises.set(@key, 'oof')
  end

  it 'responds with "OK"' do
    expect(@redises.rename(@key, @newkey)).to eq('OK')
  end

  it 'moves the data' do
    @redises.rename(@key, @newkey)
    expect(@redises.get(@newkey)).to eq('oof')
  end

  it 'raises an error when the source key is nonexistant' do
    @redises.del(@key)
    expect do
      @redises.rename(@key, @newkey)
    end.to raise_error(Redis::CommandError)
  end

  it 'responds with "OK" when key == newkey' do
    expect(@redises.rename(@key, @key)).to eq('OK')
  end

  it 'overwrites any existing value at newkey' do
    @redises.set(@newkey, 'rab')
    @redises.rename(@key, @newkey)
    expect(@redises.get(@newkey)).to eq('oof')
  end

  it 'keeps expiration' do
    @redises.expire(@key, 1000)
    @redises.rename(@key, @newkey)
    expect(@redises.ttl(@newkey)).to be > 0
  end
end
