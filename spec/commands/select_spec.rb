require 'spec_helper'

RSpec.describe '#select(db)' do
  before { @key = 'mock-redis-test:select' }

  it "returns 'OK'" do
    expect(@redises.select(0)).to eq('OK')
  end

  it "treats '0' and 0 the same" do
    @redises.select('0')
    @redises.set(@key, 'foo')
    @redises.select(0)
    expect(@redises.get(@key)).to eq('foo')
  end

  it 'switches databases' do
    @redises.select(0)
    @redises.set(@key, 'foo')

    @redises.select(1)
    expect(@redises.get(@key)).to be_nil

    @redises.select(0)
    expect(@redises.get(@key)).to eq('foo')
  end

  context '[mock only]' do
    # Time dependence introduces a bit of nondeterminism here
    before do
      @now = Time.now
      allow(Time).to receive(:now).and_return(@now)

      @mock = @redises.mock

      @mock.select(0)
      @mock.set(@key, 1)
      @mock.expire(@key, 100)

      @mock.select(1)
      @mock.set(@key, 2)
      @mock.expire(@key, 200)
    end

    it 'keeps expire times per-db' do
      @mock.select(0)
      expect(@mock.ttl(@key)).to eq(100)

      @mock.select(1)
      expect(@mock.ttl(@key)).to eq(200)
    end

    it 'keeps expire times in miliseconds per-db' do
      @mock.select(0)
      expect(100_000 - 1000..100_000 + 1000).to cover(@mock.pttl(@key))

      @mock.select(1)
      expect(200_000 - 1000..200_000 + 1000).to cover(@mock.pttl(@key))
    end
  end
end
