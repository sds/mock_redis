require 'spec_helper'

RSpec.describe '#set(key, value)' do
  let(:key) { 'mock-redis-test' }

  it "responds with 'OK'" do
    expect(@redises.set('mock-redis-test', 1)).to eq('OK')
  end

  context 'options' do
    it 'raises an error for EX seconds = 0' do
      expect do
        @redises.set('mock-redis-test', 1, ex: 0)
      end.to raise_error(Redis::CommandError, 'ERR invalid expire time in set')
    end

    it 'raises an error for PX milliseconds = 0' do
      expect do
        @redises.set('mock-redis-test', 1, px: 0)
      end.to raise_error(Redis::CommandError, 'ERR invalid expire time in set')
    end

    it 'raises an error for EXAT seconds = 0' do
      expect do
        @redises.set('mock-redis-test', 1, exat: 0)
      end.to raise_error(Redis::CommandError, 'ERR invalid expire time in set')
    end

    it 'raises an error for PXAT seconds = 0' do
      expect do
        @redises.set('mock-redis-test', 1, pxat: 0)
      end.to raise_error(Redis::CommandError, 'ERR invalid expire time in set')
    end

    it 'accepts NX' do
      @redises.del(key)
      expect(@redises.set(key, 1, nx: true)).to eq(true)
      expect(@redises.set(key, 1, nx: true)).to eq(false)
    end

    it 'accepts XX' do
      @redises.del(key)
      expect(@redises.set(key, 1, xx: true)).to eq(false)
      expect(@redises.set(key, 1)).to eq('OK')
      expect(@redises.set(key, 1, xx: true)).to eq(true)
    end

    it 'accepts EXAT' do
      @redises.del(key)
      expect(@redises.set(key, 1, exat: 1_697_197_606)).to eq('OK')
    end

    it 'accepts PXAT' do
      @redises.del(key)
      expect(@redises.set(key, 1, exat: 1_697_197_589_362)).to eq('OK')
    end

    it 'accepts GET on a string' do
      expect(@redises.set(key, '1')).to eq('OK')
      expect(@redises.set(key, '2', get: true)).to eq('1')
      expect(@redises.set(key, '3', get: true)).to eq('2')
    end

    context 'when set key is not a String' do
      it 'should error with Redis::CommandError' do
        expect(@redises.lpush(key, '1')).to eq(1)
        expect do
          @redises.set(key, '2', get: true)
        end.to raise_error(Redis::CommandError)
      end
    end

    it 'sets the ttl to -1' do
      @redises.set(key, 1)
      expect(@redises.ttl(key)).to eq(-1)
    end

    context 'with an expiry time' do
      before :each do
        Timecop.freeze
        @redises.set(key, 1, ex: 90)
      end

      after :each do
        @redises.del(key)
        Timecop.return
      end

      it 'has the TTL set' do
        expect(@redises.ttl(key)).to eq 90
      end

      it 'resets the TTL without keepttl' do
        expect do
          @redises.set(key, 2)
        end.to change { @redises.ttl(key) }.from(90).to(-1)
      end

      it 'does not change the TTL with keepttl: true' do
        expect do
          @redises.set(key, 2, keepttl: true)
        end.not_to change { @redises.ttl(key) }.from(90)
      end
    end

    it 'accepts KEEPTTL' do
      expect(@redises.set(key, 1, keepttl: true)).to eq 'OK'
    end

    it 'does not set TTL without ex' do
      @redises.set(key, 1)
      expect(@redises.ttl(key)).to eq(-1)
    end

    it 'sets the TTL' do
      Timecop.freeze do
        @redises.set(key, 1, ex: 90)
        expect(@redises.ttl(key)).to eq 90
      end
    end

    it 'raises on unknown options' do
      @redises.del(key)
      expect do
        @redises.set(key, 1, logger: :something)
      end.to raise_error(ArgumentError, /unknown keyword/)
    end

    context '[mock only]' do
      before(:all) do
        @mock = @redises.mock
      end

      before do
        @now = Time.now
        allow(Time).to receive(:now).and_return(@now)
      end

      it 'accepts EX seconds' do
        expect(@mock.set(key, 1, ex: 1)).to eq('OK')
        expect(@mock.get(key)).not_to be_nil
        allow(Time).to receive(:now).and_return(@now + 2)
        expect(@mock.get(key)).to be_nil
      end

      it 'accepts PX milliseconds' do
        expect(@mock.set(key, 1, px: 500)).to eq('OK')
        expect(@mock.get(key)).not_to be_nil
        allow(Time).to receive(:now).and_return(@now + 300 / 1000.to_f)
        expect(@mock.get(key)).not_to be_nil
        allow(Time).to receive(:now).and_return(@now + 600 / 1000.to_f)
        expect(@mock.get(key)).to be_nil
      end

      it 'accepts EXAT seconds' do
        expect(@mock.set(key, 1, exat: (@now + 1).to_i)).to eq('OK')
        expect(@mock.get(key)).not_to be_nil
        allow(Time).to receive(:now).and_return(@now + 2)
        expect(@mock.get(key)).to be_nil
      end

      it 'accepts PXAT milliseconds' do
        expect(@mock.set(key, 1, pxat: ((@now + 500).to_f * 1000).to_i)).to eq('OK')
        expect(@mock.get(key)).not_to be_nil
        allow(Time).to receive(:now).and_return(@now + 300)
        expect(@mock.get(key)).not_to be_nil
        allow(Time).to receive(:now).and_return(@now + 600)
        expect(@mock.get(key)).to be_nil
      end
    end
  end
end
