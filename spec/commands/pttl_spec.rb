require 'spec_helper'

RSpec.describe '#pttl(key)' do
  before do
    @key = 'mock-redis-test:persist'
    @redises.set(@key, 'spork')
  end

  it 'returns -1 for a key with no expiration' do
    expect(@redises.pttl(@key)).to eq(-1)
  end

  it 'returns -2 for a key that does not exist' do
    expect(@redises.pttl('mock-redis-test:nonesuch')).to eq(-2)
  end

  it 'stringifies key' do
    @redises.expire(@key, 8)
    # Don't check against Redis since millisecond timing differences are likely
    expect(@redises.send_without_checking(:pttl, @key.to_sym)).to be > 0
  end

  context '[mock only]' do
    # These are mock-only since we can't actually manipulate time in
    # the real Redis.

    before(:all) do
      @mock = @redises.mock
    end

    before do
      @now = Time.now.round
      allow(Time).to receive(:now).and_return(@now)
    end

    it "gives you the key's remaining lifespan in milliseconds" do
      @mock.expire(@key, 5)
      expect(@mock.pttl(@key)).to eq(5000)
    end
  end
end
