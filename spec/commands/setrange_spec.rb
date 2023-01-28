require 'spec_helper'

RSpec.describe '#setrange(key, offset, value)' do
  before do
    @key = 'mock-redis-test:setrange'
    @redises.set(@key, 'This is a string')
  end

  it "returns the string's new length" do
    expect(@redises.setrange(@key, 0, 'That')).to eq(16)
  end

  it 'updates part of the string' do
    @redises.setrange(@key, 0, 'That')
    expect(@redises.get(@key)).to eq('That is a string')
  end

  it 'zero-pads the string if necessary' do
    @redises.setrange(@key, 20, 'X')
    expect(@redises.get(@key)).to eq("This is a string\000\000\000\000X")
  end

  it 'stores things as strings' do
    other_key = 'mock-redis-test:setrange-other-key'
    @redises.setrange(other_key, 0, 1)
    expect(@redises.get(other_key)).to eq('1')
  end

  it_should_behave_like 'a string-only command'
end
