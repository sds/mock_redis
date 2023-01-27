require 'spec_helper'

RSpec.describe '#llen(key)' do
  before { @key = 'mock-redis-test:78407' }

  it 'returns 0 for a nonexistent key' do
    expect(@redises.llen(@key)).to eq(0)
  end

  it 'returns the length of the list' do
    5.times { @redises.lpush(@key, 'X') }
    expect(@redises.llen(@key)).to eq(5)
  end

  it_should_behave_like 'a list-only command'
end
