require 'spec_helper'

RSpec.describe '#flushall [mock only]' do
  # don't want to hurt things in the real redis that are outside our
  # namespace.
  before { @mock = @redises.mock }
  before { @key = 'mock-redis-test:select' }

  it "returns 'OK'" do
    expect(@mock.flushall).to eq('OK')
  end

  it 'removes all keys in the current DB' do
    @mock.set('k1', 'v1')
    @mock.lpush('k2', 'v2')

    @mock.flushall
    expect(@mock.keys('*')).to eq([])
  end

  it 'removes all keys in other DBs, too' do
    @mock.set('k1', 'v1')

    @mock.select(1)
    @mock.flushall
    @mock.select(0)

    expect(@mock.get('k1')).to be_nil
  end

  it 'removes expiration times' do
    @mock.set('k1', 'v1')
    @mock.expire('k1', 360_000)
    @mock.flushall
    @mock.set('k1', 'v1')
    expect(@mock.ttl('k1')).to eq(-1)
  end
end
