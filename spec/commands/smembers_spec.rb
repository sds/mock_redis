require 'spec_helper'

RSpec.describe '#smembers(key)' do
  before { @key = 'mock-redis-test:smembers' }

  it 'returns [] for an empty set' do
    expect(@redises.smembers(@key)).to eq([])
  end

  it "returns the set's members" do
    @redises.sadd(@key, 'Hello')
    @redises.sadd(@key, 'World')
    @redises.sadd(@key, 'Test')
    expect(@redises.smembers(@key)).to eq(%w[Test World Hello])
  end

  it 'returns unfrozen copies of the input' do
    input = 'a string'
    @redises.sadd(@key, input)
    output = @redises.smembers(@key).first

    expect(output).to eq input
    expect(output).to_not equal input
    expect(output).to_not be_frozen
  end

  it_should_behave_like 'a set-only command'
end
