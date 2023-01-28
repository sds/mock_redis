require 'spec_helper'

RSpec.describe '#zremrangebyrank(key, start, stop)' do
  before do
    @key = 'mock-redis-test:zremrangebyrank'
    @redises.zadd(@key, 1, 'Washington')
    @redises.zadd(@key, 2, 'Adams')
    @redises.zadd(@key, 3, 'Jefferson')
    @redises.zadd(@key, 4, 'Madison')
  end

  it 'returns the number of elements in range' do
    expect(@redises.zremrangebyrank(@key, 2, 3)).to eq(2)
  end

  it 'removes the elements' do
    @redises.zremrangebyrank(@key, 2, 3)
    expect(@redises.zrange(@key, 0, -1)).to eq(%w[Washington Adams])
  end

  it 'does nothing if start is greater than cardinality of set' do
    @redises.zremrangebyrank(@key, 5, -1)
    expect(@redises.zrange(@key, 0, -1)).to eq(%w[Washington Adams Jefferson Madison])
  end

  it_should_behave_like 'a zset-only command'
end
