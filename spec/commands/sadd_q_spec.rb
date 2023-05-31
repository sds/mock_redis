require 'spec_helper'

RSpec.describe '#sadd(key, member)' do
  before { @key = 'mock-redis-test:sadd_q' }

  it 'returns true if the set did not already contain member' do
    expect(@redises.sadd?(@key, 1)).to eq(true)
  end

  it 'returns false if the set did already contain member' do
    @redises.sadd?(@key, 1)
    expect(@redises.sadd?(@key, 1)).to eq(false)
  end

  it 'adds member to the set' do
    @redises.sadd?(@key, 1)
    @redises.sadd?(@key, 2)
    expect(@redises.smembers(@key)).to eq(%w[2 1])
  end

  describe 'adding multiple members at once' do
    it 'returns true if at least one member was added' do
      expect(@redises.sadd?(@key, [1, 2, 3])).to eq(true)
      expect(@redises.sadd?(@key, [1, 2, 3])).to eq(false)
    end

    it 'returns false if the set did already contain all members' do
      @redises.sadd?(@key, [1, 2, 3])
      expect(@redises.sadd?(@key, [1, 2, 3])).to eq(false)
    end

    it 'adds the members to the set' do
      @redises.sadd?(@key, [1, 2, 3])
      expect(@redises.smembers(@key)).to eq(%w[1 2 3])
    end

    it 'raises an error if an empty array is given' do
      expect do
        @redises.sadd?(@key, [])
      end.to raise_error(Redis::CommandError)
    end
  end

  it_should_behave_like 'a set-only command'
end
