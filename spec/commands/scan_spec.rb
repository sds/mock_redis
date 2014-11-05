require 'spec_helper'

describe '#scan' do
  subject { MockRedis::Database.new(self) }

  let(:count) { 10 }
  let(:match) { '*' }

  before do
    expect(subject).to receive_message_chain(:data, :keys).and_return(collection)
  end

  context 'when no keys are found' do
    let(:collection) { [] }

    it 'returns a 0 cursor and an empty collection' do
      expect(subject.scan(0, count: count, match: match)).to eq(['0', []])
    end
  end

  context 'when keys are found' do
    context 'when count is lower than collection size' do
      let(:collection) { (count+1).times.map {|i| "mock:key#{1}"} }
      let(:expected) { [count.to_s, collection]}

      it 'returns a the next cursor and the collection' do
        expect(subject.scan(0, count: count, match: match)).to eq(expected)
      end
    end

    context 'when count is greater or equal than collection size' do
      let(:collection) { count.times.map {|i| "mock:key#{1}"} }
      let(:expected) { ['0', collection]}

      it 'returns a 0 cursor and the collection' do
        expect(subject.scan(0, count: count, match: match)).to eq(expected)
      end
    end

    context 'when giving a custom match filter' do
      let(:match) { 'mock:key*' }
      let(:collection) { %w(mock:key mock:key2 mock:otherkey) }
      let(:expected) { ['0', %w(mock:key mock:key2)]}

      it 'returns a 0 cursor and the filtered collection' do
        expect(subject.scan(0, count: count, match: match)).to eq(expected)
      end
    end
  end
end

