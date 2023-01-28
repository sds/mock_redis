require 'spec_helper'

RSpec.describe '#sinterstore(destination, key [, key, ...])' do
  before do
    @numbers     = 'mock-redis-test:sinterstore:numbers'
    @evens       = 'mock-redis-test:sinterstore:evens'
    @primes      = 'mock-redis-test:sinterstore:primes'
    @destination = 'mock-redis-test:sinterstore:destination'

    (1..10).each { |i| @redises.sadd(@numbers, i) }
    [2, 4, 6, 8, 10].each { |i| @redises.sadd(@evens, i) }
    [2, 3, 5, 7].each { |i| @redises.sadd(@primes, i) }
  end

  it 'returns the number of elements in the resulting set' do
    expect(@redises.sinterstore(@destination, @numbers, @evens)).to eq(5)
  end

  it 'stores the resulting set' do
    @redises.sinterstore(@destination, @numbers, @evens)
    expect(@redises.smembers(@destination)).to eq(%w[10 8 6 4 2])
  end

  it 'does not store empty sets' do
    expect(@redises.sinterstore(@destination, 'mock-redis-test:nonesuch', @numbers)).to eq(0)
    expect(@redises.get(@destination)).to be_nil
  end

  it 'removes existing elements in destination' do
    @redises.sadd(@destination, 42)

    @redises.sinterstore(@destination, @primes)
    expect(@redises.smembers(@destination)).to eq(%w[7 5 3 2])
  end

  it 'raises an error if given 0 sets' do
    expect do
      @redises.sinterstore(@destination)
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if any argument is not a a set' do
    @redises.set('mock-redis-test:notset', 1)

    expect do
      @redises.sinterstore(@destination, @numbers, 'mock-redis-test:notset')
    end.to raise_error(Redis::CommandError)

    expect do
      @redises.sinterstore(@destination, 'mock-redis-test:notset', @numbers)
    end.to raise_error(Redis::CommandError)
  end
end
