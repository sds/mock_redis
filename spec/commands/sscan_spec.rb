require 'spec_helper'

describe '#sscan' do
  let(:count) { 10 }
  let(:match) { '*' }
  let(:key) { 'mock-redis-test:sscan' }

  context 'when the set does not exist' do
    it 'returns a 0 cursor and an empty collection' do
      expect(@redises.sscan(key, 0, count: count, match: match)).to eq(['0', []])
    end
  end

  context 'when the set exists' do
    before do
      @redises.sadd(key, 'Hello')
      @redises.sadd(key, 'World')
      @redises.sadd(key, 'Test')
    end

    let(:expected) { ['0', ['Test', 'World', 'Hello']] }

    it 'returns a 0 cursor and the collection' do
      expect(@redises.sscan(key, 0, count: count)).to eq(expected)
    end
  end
end
