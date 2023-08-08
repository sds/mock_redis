require 'spec_helper'

RSpec.describe '#scan' do
  subject { MockRedis::Database.new(self) }

  let(:count) { 10 }
  let(:match) { '*' }

  before do
    allow(subject).to receive(:data).and_return(data)
  end

  context 'when no keys are found' do
    let(:data) { {} }

    it 'returns a 0 cursor and an empty collection' do
      expect(subject.scan(0, count: count, match: match)).to eq(['0', []])
    end
  end

  context 'when keys are found' do
    context 'when count is lower than collection size' do
      let(:data) { Array.new(count * 2) { |i| "mock:key#{i}" }.to_h { |e| [e, nil] } }
      let(:expected_first) { [count.to_s, data.keys[0...count]] }
      let(:expected_second) { ['0', data.keys[count..]] }

      it 'returns a the next cursor and the collection' do
        expect(subject.scan(0, count: count, match: match)).to eq(expected_first)
      end

      it 'returns the correct results of the next cursor' do
        expect(subject.scan(count, count: count, match: match)).to eq(expected_second)
      end
    end

    context 'when count is greater or equal than collection size' do
      let(:data) { Array.new(count) { |i| "mock:key#{i}" }.to_h { |e| [e, nil] } }
      let(:expected) { ['0', data.keys] }

      it 'returns a 0 cursor and the collection' do
        expect(subject.scan(0, count: count, match: match)).to eq(expected)
      end
    end

    context 'when cursor is greater than collection size' do
      let(:data) { Array.new(count) { |i| "mock:key#{i}" }.to_h { |e| [e, nil] } }
      let(:expected) { ['0', []] }

      it 'returns a 0 cursor and empty collection' do
        expect(subject.scan(20, count: count, match: match)).to eq(expected)
      end
    end

    context 'when giving a custom match filter' do
      let(:match) { 'mock:key*' }
      let(:data) { ['mock:key', 'mock:key2', 'mock:otherkey'].to_h { |e| [e, nil] } }
      let(:expected) { ['0', %w[mock:key mock:key2]] }

      it 'returns a 0 cursor and the filtered collection' do
        expect(subject.scan(0, count: count, match: match)).to eq(expected)
      end
    end

    context 'when giving a custom match filter with a hash tag' do
      let(:match) { 'mock:key:{1}:*' }
      let(:data) { ['mock:key:{1}:1', 'mock:key:{1}:2', 'mock:key:{2}:1'].to_h { |e| [e, nil] } }
      let(:expected) { ['0', %w[mock:key:{1}:1 mock:key:{1}:2]] }

      it 'returns a 0 cursor and the filtered collection' do
        expect(subject.scan(0, count: count, match: match)).to eq(expected)
      end
    end

    context 'when giving a custom match and type filter' do
      let(:data) do
        { 'mock:stringkey' => 'mockvalue',
          'mock:listkey' => ['mockvalue1'],
          'mock:hashkey' => { 'mocksubkey' => 'mockvalue' },
          'mock:setkey' => Set.new(['mockvalue']),
          'mock:zsetkey' => MockRedis::Zset.new(['mockvalue']) }
      end
      let(:match) { 'mock:*' }
      let(:type) { 'string' }
      let(:expected) { ['0', %w[mock:stringkey]] }

      it 'returns a 0 cursor and the filtered collection' do
        expect(subject.scan(0, count: count, match: match, type: type)).to eq(expected)
      end
    end
  end
end
