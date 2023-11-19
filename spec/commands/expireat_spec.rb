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

  it 'works with options', redis: '7.0' do
    expect(@redises.expire(@key, Time.now.to_i + 20)).to eq(true)
    expect(@redises.expire(@key, Time.now.to_i + 10, lt: true)).to eq(true)
    expect(@redises.expire(@key, Time.now.to_i + 15, lt: true)).to eq(false)
    expect(@redises.expire(@key, Time.now.to_i + 20, gt: true)).to eq(true)
    expect(@redises.expire(@key, Time.now.to_i + 15, gt: true)).to eq(false)
    expect(@redises.expire(@key, Time.now.to_i + 10, xx: true)).to eq(true)
    expect(@redises.expire(@key, Time.now.to_i + 10, nx: true)).to eq(false)
    expect(@redises.persist(@key)).to eq(true)
    expect(@redises.expire(@key, Time.now.to_i + 10, xx: true)).to eq(false)
    expect(@redises.expire(@key, Time.now.to_i + 10, nx: true)).to eq(true)
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

    it_should_behave_like 'raises on invalid expire command options', :expireat

    it 'removes keys after enough time has passed' do
      @mock.expireat(@key, @now.to_i + 5)
      allow(Time).to receive(:now).and_return(@now + 5)
      expect(@mock.get(@key)).to be_nil
    end
  end
end
