require 'spec_helper'

RSpec.describe '#get(key)' do
  before do
    @key = 'mock-redis-test:73288'
  end

  it 'returns nil for a nonexistent value' do
    expect(@redises.get('mock-redis-test:does-not-exist')).to be_nil
  end

  it 'returns a stored string value' do
    @redises.set(@key, 'forsooth')
    expect(@redises.get(@key)).to eq('forsooth')
  end

  it 'treats integers as strings' do
    @redises.set(@key, 100)
    expect(@redises.get(@key)).to eq('100')
  end

  it 'stringifies key' do
    key = :a_symbol

    @redises.set(key, 'hello')
    expect(@redises.get(key.to_s)).to eq('hello')
    expect(@redises.get(key)).to eq('hello')
  end

  it_should_behave_like 'a string-only command'
end
