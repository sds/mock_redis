require 'spec_helper'

RSpec.describe '#persist(key)' do
  before do
    @key = 'mock-redis-test:persist'
    @redises.set(@key, 'spork')
  end

  it 'returns true for a key with a timeout' do
    @redises.expire(@key, 10_000)
    expect(@redises.persist(@key)).to eq(true)
  end

  it 'returns false for a key with no timeout' do
    expect(@redises.persist(@key)).to eq(false)
  end

  it 'returns false for a key that does not exist' do
    expect(@redises.persist('mock-redis-test:nonesuch')).to eq(false)
  end

  it 'removes the timeout' do
    @redises.expire(@key, 10_000)
    @redises.persist(@key)
    expect(@redises.persist(@key)).to eq(false)
  end

  context '[mock only]' do
    # These are mock-only since we can't actually manipulate time in
    # the real Redis.

    before(:all) do
      @mock = @redises.mock
    end

    before do
      @now = Time.now
      allow(Time).to receive(:now).and_return(@now)
    end

    it 'makes keys stay around' do
      @mock.expire(@key, 5)
      @mock.persist(@key)
      allow(Time).to receive(:now).and_return(@now + 5)
      expect(@mock.get(@key)).not_to be_nil
    end
  end
end
