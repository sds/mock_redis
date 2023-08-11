require 'spec_helper'

RSpec.describe '#scan_each' do
  subject { MockRedis::Database.new(self) }

  let(:match) { '*' }

  before do
    allow(subject).to receive(:data).and_return(data)
  end

  context 'when no keys are found' do
    let(:data) { {} }

    it 'does not iterate over any elements' do
      expect(subject.scan_each.to_a).to be_empty
    end
  end

  context 'when keys are found' do
    context 'when no match filter is supplied' do
      let(:data) { Array.new(20) { |i| "mock:key#{i}" }.to_h { |e| [e, nil] } }

      it 'iterates over each item in the collection' do
        expect(subject.scan_each.to_a).to match_array(data.keys)
      end
    end

    context 'when giving a custom match filter' do
      let(:match) { 'mock:key*' }
      let(:data) { ['mock:key', 'mock:key2', 'mock:otherkey'].to_h { |e| [e, nil] } }
      let(:expected) { %w[mock:key mock:key2] }

      it 'iterates over each item in the filtered collection' do
        expect(subject.scan_each(match: match).to_a).to match_array(expected)
      end
    end

    context 'when giving a custom match filter with a hash tag' do
      let(:match) { 'mock:key:{1}:*' }
      let(:data) { ['mock:key:{1}:1', 'mock:key:{1}:2', 'mock:key:{2}:1'].to_h { |e| [e, nil] } }
      let(:expected) { %w[mock:key:{1}:1 mock:key:{1}:2] }

      it 'returns a 0 cursor and the filtered collection' do
        expect(subject.scan_each(match: match)).to match_array(expected)
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
      let(:expected) { %w[mock:stringkey] }

      it 'iterates over each item in the filtered collection' do
        expect(subject.scan_each(match: match, type: type)).to match_array(expected)
      end
    end
  end
end
