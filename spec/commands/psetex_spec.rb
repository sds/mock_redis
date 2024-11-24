require 'spec_helper'

RSpec.describe '#psetex(key, miliseconds, value)' do
  before { @key = 'mock-redis-test:setex' }

  it "responds with 'OK'" do
    expect(@redises.psetex(@key, 10, 'value')).to eq('OK')
  end

  it 'sets the value' do
    @redises.psetex(@key, 10_000, 'value')
    expect(@redises.get(@key)).to eq('value')
  end

  it 'sets the expiration time' do
    @redises.psetex(@key, 10_000, 'value')

    # no guarantee these are the same
    expect(@redises.real.ttl(@key)).to be > 0
    expect(@redises.mock.ttl(@key)).to be > 0
  end

  it 'converts time correctly' do
    @redises.psetex(@key, 10_000_000, 'value')

    expect(@redises.mock.ttl(@key)).to be > 9_000
  end

  context 'when expiration time is zero' do
    let(:message) { /ERR invalid expire time in psetex/ }

    it 'raises Redis::CommandError' do
      expect do
        @redises.psetex(@key, 0, 'value')
      end.to raise_error(Redis::CommandError, message)
    end
  end

  context 'when expiration time is negative' do
    let(:message) { /ERR invalid expire time in psetex/ }

    it 'raises Redis::CommandError' do
      expect do
        @redises.psetex(@key, -2, 'value')
      end.to raise_error(Redis::CommandError, message)
    end
  end
end
