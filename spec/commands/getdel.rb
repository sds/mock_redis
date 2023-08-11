require 'spec_helper'

RSpec.describe '#getdel(key)' do
  before do
    @key = 'mock-redis-test:73288'
  end

  it 'returns nil for a nonexistent value' do
    expect(@redises.getdel('mock-redis-test:does-not-exist')).to be_nil
  end

  it 'returns a stored string value' do
    @redises.set(@key, 'forsooth')
    expect(@redises.getdel(@key)).to eq('forsooth')
  end

  it 'deletes the key after returning it' do
    @redises.set(@key, 'forsooth')
    @redises.getdel(@key)
    expect(@redises.get(@key)).to be_nil
  end

  it_should_behave_like 'a string-only command'
end
