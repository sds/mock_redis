require 'spec_helper'

describe '#xadd(key, id, [field, value, ...])' do
  before { @key = 'mock-redis-test:zadd' }

  it "returns an id based on the timestamp" do
    expect(@redises.xadd(@key, '*', 'key', 'value')).to match /\d+-0/
  end
end
