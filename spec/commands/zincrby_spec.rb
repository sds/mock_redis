require 'spec_helper'

RSpec.describe '#zincrby(key, increment, member)' do
  before do
    @key = 'mock-redis-test:zincrby'
    @redises.zadd(@key, 1, 'bert')
  end

  it 'returns the new score as a string' do
    expect(@redises.zincrby(@key, 10, 'bert')).to eq(11.0)
  end

  it "updates the item's score" do
    @redises.zincrby(@key, 10, 'bert')
    expect(@redises.zscore(@key, 'bert')).to eq(11.0)
  end

  it 'handles integer members correctly' do
    member = 11
    @redises.zadd(@key, 1, member)
    @redises.zincrby(@key, 1, member)
    expect(@redises.zscore(@key, member)).to eq(2.0)
  end

  it 'adds missing members with score increment' do
    expect(@redises.zincrby(@key, 5.5, 'bigbird')).to eq(5.5)
  end

  it_should_behave_like 'arg 1 is a score'
  it_should_behave_like 'a zset-only command'
end
