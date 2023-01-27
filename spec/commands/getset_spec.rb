require 'spec_helper'

RSpec.describe '#getrange(key, value)' do
  before do
    @key = 'mock-redis-test:getset'
    @redises.set(@key, 'oldvalue')
  end

  it 'returns the old value' do
    expect(@redises.getset(@key, 'newvalue')).to eq('oldvalue')
  end

  it 'sets the value to the new value' do
    @redises.getset(@key, 'newvalue')
    expect(@redises.get(@key)).to eq('newvalue')
  end

  it 'returns nil for nonexistent keys' do
    expect(@redises.getset('mock-redis-test:not-found', 1)).to be_nil
  end

  it_should_behave_like 'a string-only command'
end
