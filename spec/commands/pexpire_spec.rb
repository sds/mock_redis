require 'spec_helper'

RSpec.describe '#pexpire(key, ms)' do
  before do
    @key = 'mock-redis-test:pexpire'
    @redises.set(@key, 'spork')
  end

  it 'returns true for a key that exists' do
    expect(@redises.pexpire(@key, 1)).to eq(true)
  end

  it 'returns false for a key that does not exist' do
    expect(@redises.pexpire('mock-redis-test:nonesuch', 1)).to eq(false)
  end

  it 'removes a key immediately when ms==0' do
    @redises.pexpire(@key, 0)
    expect(@redises.get(@key)).to be_nil
  end

  it 'raises an error if ms is bogus' do
    expect do
      @redises.pexpire(@key, 'a couple minutes or so')
    end.to raise_error(Redis::CommandError)
  end

  it 'stringifies key' do
    expect(@redises.pexpire(@key.to_sym, 9)).to eq(true)
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

    it 'removes keys after enough time has passed' do
      @mock.pexpire(@key, 5)
      allow(Time).to receive(:now).and_return(@now + Rational(6, 1000))
      expect(@mock.get(@key)).to be_nil
    end

    it 'updates an existing pexpire time' do
      @mock.pexpire(@key, 5)
      @mock.pexpire(@key, 6)

      allow(Time).to receive(:now).and_return(@now + Rational(5, 1000))
      expect(@mock.get(@key)).not_to be_nil
    end

    context 'expirations on a deleted key' do
      before { @mock.del(@key) }

      it 'cleans up the expiration once the key is gone (string)' do
        @mock.set(@key, 'string')
        @mock.pexpire(@key, 2)
        @mock.del(@key)
        @mock.set(@key, 'string')

        allow(Time).to receive(:now).and_return(@now + 0.003)

        expect(@mock.get(@key)).not_to be_nil
      end

      it 'cleans up the expiration once the key is gone (list)' do
        @mock.rpush(@key, 'coconuts')
        @mock.pexpire(@key, 2)
        @mock.rpop(@key)

        @mock.rpush(@key, 'coconuts')

        allow(Time).to receive(:now).and_return(@now + 0.003)

        expect(@mock.lindex(@key, 0)).not_to be_nil
      end
    end
  end
end
