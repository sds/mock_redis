require 'spec_helper'

RSpec.describe '#setex(key, seconds, value)' do
  before { @key = 'mock-redis-test:setex' }

  it "responds with 'OK'" do
    expect(@redises.setex(@key, 10, 'value')).to eq('OK')
  end

  it 'sets the value' do
    @redises.setex(@key, 10_000, 'value')
    expect(@redises.get(@key)).to eq('value')
  end

  it 'sets the expiration time' do
    @redises.setex(@key, 10_000, 'value')

    # no guarantee these are the same
    expect(@redises.real.ttl(@key)).to be > 0
    expect(@redises.mock.ttl(@key)).to be > 0
  end

  context 'when expiration time is zero' do
    it 'raises Redis::CommandError' do
      expect do
        @redises.setex(@key, 0, 'value')
      end.to raise_error(Redis::CommandError, /ERR invalid expire time in setex/)
    end
  end

  context 'when expiration time is negative' do
    it 'raises Redis::CommandError' do
      expect do
        @redises.setex(@key, -2, 'value')
      end.to raise_error(Redis::CommandError, /ERR invalid expire time in setex/)
    end
  end
end
