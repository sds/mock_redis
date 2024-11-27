require 'spec_helper'

RSpec.describe '#rpop(key)' do
  before { @key = 'mock-redis-test:43093' }

  it 'returns and removes the first element of a list' do
    @redises.lpush(@key, 1)
    @redises.lpush(@key, 2)

    expect(@redises.rpop(@key)).to eq('1')

    expect(@redises.llen(@key)).to eq(1)
  end

  it 'returns nil if the list is empty' do
    @redises.lpush(@key, 'foo')
    @redises.rpop(@key)

    expect(@redises.rpop(@key)).to be_nil
  end

  it 'returns nil for nonexistent values' do
    expect(@redises.rpop(@key)).to be_nil
  end

  it 'removes empty lists' do
    @redises.lpush(@key, 'foo')
    @redises.rpop(@key)

    expect(@redises.get(@key)).to be_nil
  end

  context 'when count != nil' do
    it 'returns array with one element if count == 1' do
      @redises.rpush(@key, %w[one two three four five])

      expect(@redises.rpop(@key, 1)).to eq(%w[five])
      expect(@redises.lrange(@key, 0, -1)).to eq(%w[one two three four])
    end

    it 'returns the number of records requested' do
      @redises.rpush(@key, %w[one two three four five])

      expect(@redises.rpop(@key, 2)).to eq(%w[five four])
      expect(@redises.lrange(@key, 0, -1)).to eq(%w[one two three])
    end

    it 'returns nil for nonexistent key' do
      expect(@redises.rpop(@key, 2)).to be_nil
    end

    it 'returns all records when requesting more than list length' do
      @redises.rpush(@key, %w[one two three])

      expect(@redises.rpop(@key, 10)).to eq(%w[three two one])
      expect(@redises.lrange(@key, 0, -1)).to eq([])
    end
  end

  it_should_behave_like 'a list-only command' do
    let(:args) { [1] }
    let(:error) do
      [
        Redis::CommandError,
        /WRONGTYPE Operation against a key holding the wrong kind of value/
      ]
    end
  end
end
