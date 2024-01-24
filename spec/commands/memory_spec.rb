require 'spec_helper'

RSpec.describe '#memory usage [mock only]' do
  it 'only handles the usage subcommand' do
    expect { @redises.mock.call(%w[memory stats]) }.to raise_error(ArgumentError)
  end

  context 'when the key does not exist' do
    before { @redises.real.del('foo') }

    it 'returns nil' do
      expect(@redises.call(%w[memory usage foo])).to be_nil
    end
  end

  context 'when the key does exist' do
    before { @redises.set('foo', 'a' * 100) }

    it 'returns the memory usage' do
      expect(@redises.call(%w[memory usage foo])).to be_a(Integer)
    end
  end
end
