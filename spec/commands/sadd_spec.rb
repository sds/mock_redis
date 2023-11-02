require 'spec_helper'

RSpec.describe '#sadd(key, member)' do
  before { @key = 'mock-redis-test:sadd' }

  context 'sadd' do
    it 'returns true if the set did not already contain member' do
      expect(@redises.sadd(@key, 1)).to eq(true)
    end

    it 'returns false if the set did already contain member' do
      @redises.sadd(@key, 1)
      expect(@redises.sadd(@key, 1)).to eq(false)
    end

    it 'adds member to the set' do
      @redises.sadd(@key, 1)
      @redises.sadd(@key, 2)
      expect(@redises.smembers(@key)).to eq(%w[2 1])
    end
  end

  context 'sadd?' do
    it 'returns true if the set did not already contain member' do
      expect(@redises.sadd?(@key, 1)).to eq(true)
    end

    it 'returns false if the set did already contain member' do
      @redises.sadd(@key, 1)
      expect(@redises.sadd?(@key, 1)).to eq(false)
    end

    it 'adds member to the set' do
      @redises.sadd?(@key, 1)
      @redises.sadd?(@key, 2)
      expect(@redises.smembers(@key)).to eq(%w[2 1])
    end
  end

  describe 'adding multiple members at once' do
    it 'returns the amount of added members' do
      expect(@redises.sadd(@key, [1, 2, 3])).to eq(3)
      expect(@redises.sadd(@key, [1, 2, 3, 4])).to eq(1)
    end

    it 'returns 0 if the set did already contain all members' do
      @redises.sadd(@key, [1, 2, 3])
      expect(@redises.sadd(@key, [1, 2, 3])).to eq(0)
    end

    it 'adds the members to the set' do
      @redises.sadd(@key, [1, 2, 3])
      expect(@redises.smembers(@key)).to eq(%w[1 2 3])
    end

    it 'adds an Array as a stringified member' do
      @redises.sadd(@key, [[1], 2, 3])
      expect(@redises.smembers(@key)).to eq(%w[[1] 2 3])
    end

    it 'raises an error if an empty array is given' do
      expect do
        @redises.sadd(@key, [])
      end.to raise_error(Redis::CommandError)
    end
  end

  it_should_behave_like 'a set-only command'
end
