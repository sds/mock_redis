require 'spec_helper'

RSpec.describe '#flushdb [mock only]' do
  # don't want to hurt things in the real redis that are outside our
  # namespace.
  before { @mock = @redises.mock }
  before { @key = 'mock-redis-test:select' }

  it "returns 'OK'" do
    expect(@mock.flushdb).to eq('OK')
  end

  it 'removes all keys in the current DB' do
    @mock.set('k1', 'v1')
    @mock.lpush('k2', 'v2')

    @mock.flushdb
    expect(@mock.keys('*')).to eq([])
  end

  it 'leaves other databases alone' do
    @mock.set('k1', 'v1')

    @mock.select(1)
    @mock.flushdb
    @mock.select(0)

    expect(@mock.get('k1')).to eq('v1')
  end

  it 'removes expiration times' do
    @mock.set('k1', 'v1')
    @mock.expire('k1', 360_000)
    @mock.flushdb
    @mock.set('k1', 'v1')
    expect(@mock.ttl('k1')).to eq(-1)
  end
end
