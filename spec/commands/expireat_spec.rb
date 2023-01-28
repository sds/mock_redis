require 'spec_helper'

RSpec.describe '#expireat(key, timestamp)' do
  before do
    @key = 'mock-redis-test:expireat'
    @redises.set(@key, 'spork')
  end

  it 'returns true for a key that exists' do
    expect(@redises.expireat(@key, Time.now.to_i + 1)).to eq(true)
  end

  it 'returns false for a key that does not exist' do
    expect(@redises.expireat('mock-redis-test:nonesuch', Time.now.to_i + 1)).to eq(false)
  end

  it 'removes a key immediately when timestamp is now' do
    @redises.expireat(@key, Time.now.to_i)
    expect(@redises.get(@key)).to be_nil
  end

  it "raises an error if you don't give it a Unix timestamp" do
    expect do
      @redises.expireat(@key, Time.now) # oops, forgot .to_i
    end.to raise_error(Redis::CommandError)
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

    it 'removes keys after enough time has passed' do
      @mock.expireat(@key, @now.to_i + 5)
      allow(Time).to receive(:now).and_return(@now + 5)
      expect(@mock.get(@key)).to be_nil
    end
  end
end
