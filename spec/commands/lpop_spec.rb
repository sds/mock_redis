require 'spec_helper'

RSpec.describe '#lpop(key)' do
  before { @key = 'mock-redis-test:65374' }

  it 'returns and removes the first element of a list' do
    @redises.lpush(@key, 1)
    @redises.lpush(@key, 2)

    expect(@redises.lpop(@key)).to eq('2')

    expect(@redises.llen(@key)).to eq(1)
  end

  it 'returns nil if the list is empty' do
    @redises.lpush(@key, 'foo')
    @redises.lpop(@key)

    expect(@redises.lpop(@key)).to be_nil
  end

  it 'returns nil for nonexistent values' do
    expect(@redises.lpop(@key)).to be_nil
  end

  it 'removes empty lists' do
    @redises.lpush(@key, 'foo')
    @redises.lpop(@key)

    expect(@redises.get(@key)).to be_nil
  end

  context 'requesting multiple records to be popped in the 3rd arg' do
    let(:count) { 10 }

    before { count.times { @redises.lpush(@key, _1) } }

    it 'returns the number of records requested' do
      expect(@redises.lpop(@key, count)).to eq((count - 1).downto(0).map(&:to_s))
    end

    context 'when there are no records' do
      let(:count) { 0 }
      it 'returns nil' do
        expect(@redises.lpop(@key, 10)).to eq(nil)
      end
    end

    context 'when there are more records than requested' do
      let(:count) { 20 }

      it 'returns the most recent 10 records' do
        expect(@redises.lpop(@key, 10)).to eq((count - 1).downto(10).map(&:to_s))
      end
    end

    context 'when requesting more records than exist' do
      it 'should return only the valid records in the bucket' do
        expect(@redises.lpop(@key, 1_000_000)).to eq((count - 1).downto(0).map(&:to_s))
      end
    end
  end

  let(:default_error) { RedisMultiplexer::MismatchedResponse }
  it_should_behave_like 'a list-only command'
end
