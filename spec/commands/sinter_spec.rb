require 'spec_helper'

RSpec.describe '#sinter(key [, key, ...])' do
  before do
    @numbers = 'mock-redis-test:sinter:numbers'
    @evens   = 'mock-redis-test:sinter:evens'
    @primes  = 'mock-redis-test:sinter:primes'

    (1..10).each { |i| @redises.sadd(@numbers, i) }
    [2, 4, 6, 8, 10].each { |i| @redises.sadd(@evens, i) }
    [2, 3, 5, 7].each { |i| @redises.sadd(@primes, i) }
  end

  it 'returns the elements in the resulting set' do
    expect(@redises.sinter(@evens, @primes)).to eq(['2'])
  end

  it 'raises error when key is not set' do
    expect do
      @redises.sinter(nil, 'mock-redis-test:nonesuch')
    end.to raise_error(TypeError)
  end

  it 'raises an error if given 0 sets' do
    expect do
      @redises.sinter
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if any argument is not a a set' do
    @redises.set('mock-redis-test:notset', 1)

    expect do
      @redises.sinter(@numbers, 'mock-redis-test:notset')
    end.to raise_error(Redis::CommandError)

    expect do
      @redises.sinter('mock-redis-test:notset', @numbers)
    end.to raise_error(Redis::CommandError)
  end
end
