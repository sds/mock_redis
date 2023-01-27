require 'spec_helper'

RSpec.describe '#sdiff(key [, key, ...])' do
  before do
    @numbers = 'mock-redis-test:sdiff:numbers'
    @evens   = 'mock-redis-test:sdiff:odds'
    @primes  = 'mock-redis-test:sdiff:primes'

    (1..10).each { |i| @redises.sadd(@numbers, i) }
    [2, 4, 6, 8, 10].each { |i| @redises.sadd(@evens, i) }
    [2, 3, 5, 7].each { |i| @redises.sadd(@primes, i) }
  end

  it 'returns the first set minus the second set' do
    expect(@redises.sdiff(@numbers, @evens)).to eq(%w[1 3 5 7 9])
  end

  it 'returns the first set minus all the other sets' do
    expect(@redises.sdiff(@numbers, @evens, @primes)).to eq(%w[1 9])
  end

  it 'treats missing keys as empty sets' do
    expect(@redises.sdiff(@evens, 'mock-redis-test:nonesuch')).to eq(%w[2 4 6 8 10])
  end

  it 'returns the first set when called with a single argument' do
    expect(@redises.sdiff(@primes)).to eq(%w[2 3 5 7])
  end

  it 'raises an error if given 0 arguments' do
    expect do
      @redises.sdiff
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if any argument is not a a set' do
    @redises.set('foo', 1)

    expect do
      @redises.sdiff(@numbers, 'foo')
    end.to raise_error(Redis::CommandError)

    expect do
      @redises.sdiff('foo', @numbers)
    end.to raise_error(Redis::CommandError)
  end
end
