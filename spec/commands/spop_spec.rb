require 'spec_helper'

RSpec.describe '#spop(key)' do
  before do
    @key = 'mock-redis-test:spop'

    @redises.sadd(@key, 'value')
  end

  it 'returns a member of the set' do
    expect(@redises.spop(@key)).to eq('value')
  end

  it 'removes a member of the set' do
    @redises.spop(@key)
    expect(@redises.smembers(@key)).to eq([])
  end

  it 'returns nil if the set is empty' do
    @redises.spop(@key)
    expect(@redises.spop(@key)).to be_nil
  end

  it 'returns an array if count is not nil' do
    @redises.sadd(@key, 'value2')
    expect(@redises.spop(@key, 2)).to eq(%w[value value2])
  end

  it 'returns only whats in the set' do
    expect(@redises.spop(@key, 2)).to eq(['value'])
    expect(@redises.smembers(@key)).to eq([])
  end

  it 'returns an empty array if count is not nil and the set it empty' do
    @redises.spop(@key)
    expect(@redises.spop(@key, 100)).to eq([])
  end

  it_should_behave_like 'a set-only command'
end
