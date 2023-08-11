require 'spec_helper'

RSpec.describe '#getrange(key, start, stop)' do
  before do
    @key = 'mock-redis-test:getrange'
    @redises.set(@key, 'This is a string')
  end

  it 'returns a substring' do
    expect(@redises.getrange(@key, 0, 3)).to eq('This')
  end

  it 'works with negative indices' do
    expect(@redises.getrange(@key, -3, -1)).to eq('ing')
  end

  it 'limits the result to the actual length of the string' do
    expect(@redises.getrange(@key, 10, 100)).to eq('string')
  end

  it_should_behave_like 'a string-only command'
end
