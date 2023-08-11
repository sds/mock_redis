require 'spec_helper'

RSpec.describe '#strlen(key)' do
  before do
    @key = 'mock-redis-test:73288'
    @redises.set(@key, '5 ∈ (0..10)')
  end

  it "returns the string's length in bytes" do
    expect(@redises.strlen(@key)).to eq(13)
  end

  it 'returns 0 for a nonexistent value' do
    expect(@redises.strlen('mock-redis-test:does-not-exist')).to eq(0)
  end

  it_should_behave_like 'a string-only command'
end
