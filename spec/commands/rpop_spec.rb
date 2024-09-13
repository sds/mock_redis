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

  it_should_behave_like 'a list-only command' do
    let(:args) { [1] }
    let(:error) do
      [Redis::CommandError, 'WRONGTYPE Operation against a key holding the wrong kind of value']
    end
  end
end
