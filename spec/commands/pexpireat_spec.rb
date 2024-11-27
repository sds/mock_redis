require 'spec_helper'

RSpec.describe '#pexpireat(key, timestamp_ms)' do
  before do
    @key = 'mock-redis-test:pexpireat'
    @redises.set(@key, 'spork')
  end

  def now_ms
    (Time.now.to_f * 1000).to_i
  end

  it 'returns true for a key that exists' do
    expect(@redises.pexpireat(@key, now_ms + 1)).to eq(true)
  end

  it 'returns false for a key that does not exist' do
    expect(@redises.pexpireat('mock-redis-test:nonesuch',
                       now_ms + 1)).to eq(false)
  end

  it 'removes a key immediately when timestamp is now' do
    @redises.pexpireat(@key, now_ms)
    expect(@redises.get(@key)).to be_nil
  end

  it 'returns true when time object is provided' do
    expect(@redises.pexpireat(@key, Time.now)).to eq true
  end

  it 'works with options', redis: '7.0' do
    expect(@redises.expire(@key, now_ms + 20)).to eq(true)
    expect(@redises.expire(@key, now_ms + 10, lt: true)).to eq(true)
    expect(@redises.expire(@key, now_ms + 15, lt: true)).to eq(false)
    expect(@redises.expire(@key, now_ms + 20, gt: true)).to eq(true)
    expect(@redises.expire(@key, now_ms + 15, gt: true)).to eq(false)
    expect(@redises.expire(@key, now_ms + 10, xx: true)).to eq(true)
    expect(@redises.expire(@key, now_ms + 10, nx: true)).to eq(false)
    expect(@redises.persist(@key)).to eq(true)
    expect(@redises.expire(@key, now_ms + 10, xx: true)).to eq(false)
    expect(@redises.expire(@key, now_ms + 10, nx: true)).to eq(true)
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

    it_should_behave_like 'raises on invalid expire command options', :pexpireat

    it 'removes keys after enough time has passed' do
      @mock.pexpireat(@key, (@now.to_f * 1000).to_i + 5)
      allow(Time).to receive(:now).and_return(@now + 0.006)
      expect(@mock.get(@key)).to be_nil
    end
  end
end
