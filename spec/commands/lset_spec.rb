require 'spec_helper'

RSpec.describe '#lset(key, index, value)' do
  before do
    @key = 'mock-redis-test:21522'

    @redises.lpush(@key, 'v1')
    @redises.lpush(@key, 'v0')
  end

  it "returns 'OK'" do
    expect(@redises.lset(@key, 0, 'newthing')).to eq('OK')
  end

  it "sets the list's value at index to value" do
    @redises.lset(@key, 0, 'newthing')
    expect(@redises.lindex(@key, 0)).to eq('newthing')
  end

  it "sets the list's value at index to value when the index is a string" do
    @redises.lset(@key, '0', 'newthing')
    expect(@redises.lindex(@key, 0)).to eq('newthing')
  end

  it 'stringifies value' do
    @redises.lset(@key, 0, 12_345)
    expect(@redises.lindex(@key, 0)).to eq('12345')
  end

  it 'raises an exception for nonexistent keys' do
    expect do
      @redises.lset('mock-redis-test:bogus-key', 100, 'value')
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an exception for out-of-range indices' do
    expect do
      @redises.lset(@key, 100, 'value')
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a list-only command'
end
