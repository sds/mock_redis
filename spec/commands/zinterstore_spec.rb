require 'spec_helper'

RSpec.describe '#zinterstore(destination, keys, '\
               '[:weights => [w,w,], [:aggregate => :sum|:min|:max])' do
  before do
    @odds   = 'mock-redis-test:zinterstore:odds'
    @primes = 'mock-redis-test:zinterstore:primes'
    @dest   = 'mock-redis-test:zinterstore:dest'

    @redises.zadd(@odds, 1, 'one')
    @redises.zadd(@odds, 3, 'three')
    @redises.zadd(@odds, 5, 'five')
    @redises.zadd(@odds, 7, 'seven')
    @redises.zadd(@odds, 9, 'nine')

    @redises.zadd(@primes, 2, 'two')
    @redises.zadd(@primes, 3, 'three')
    @redises.zadd(@primes, 5, 'five')
    @redises.zadd(@primes, 7, 'seven')
  end

  it 'returns the number of elements in the new set' do
    expect(@redises.zinterstore(@dest, [@odds, @primes])).to eq(3)
  end

  it "sums the members' scores by default" do
    @redises.zinterstore(@dest, [@odds, @primes])
    expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
      [['three', 6.0], ['five', 10.0], ['seven', 14.0]]
    )
  end

  it 'removes existing elements in destination' do
    @redises.zadd(@dest, 10, 'ten')

    @redises.zinterstore(@dest, [@primes])
    expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
      [['two', 2.0], ['three', 3.0], ['five', 5.0], ['seven', 7.0]]
    )
  end

  it 'raises an error if keys is empty' do
    expect do
      @redises.zinterstore(@dest, [])
    end.to raise_error(Redis::CommandError)
  end

  context 'when used with a set' do
    before do
      @primes_text = 'mock-redis-test:zinterstore:primes-text'

      @redises.sadd(@primes_text, 'two')
      @redises.sadd(@primes_text, 'three')
      @redises.sadd(@primes_text, 'five')
      @redises.sadd(@primes_text, 'seven')
    end

    it 'returns the number of elements in the new set' do
      expect(@redises.zinterstore(@dest, [@odds, @primes_text])).to eq(3)
    end

    it 'sums the scores, substituting 1.0 for set values' do
      @redises.zinterstore(@dest, [@odds, @primes_text])
      expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
        [['three', 4.0], ['five', 6.0], ['seven', 8.0]]
      )
    end
  end

  context 'when used with a non-coercible structure' do
    before do
      @non_set = 'mock-redis-test:zinterstore:non-set'

      @redises.set(@non_set, 'one')
    end
    it 'raises an error for wrong value type' do
      expect do
        @redises.zinterstore(@dest, [@odds, @non_set])
      end.to raise_error(Redis::CommandError)
    end
  end

  context 'the :weights argument' do
    it 'multiplies the scores by the weights while aggregating' do
      @redises.zinterstore(@dest, [@odds, @primes], :weights => [2, 3])
      expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
        [['three', 15.0], ['five', 25.0], ['seven', 35.0]]
      )
    end

    it 'raises an error if the number of weights != the number of keys' do
      expect do
        @redises.zinterstore(@dest, [@odds, @primes], :weights => [1, 2, 3])
      end.to raise_error(Redis::CommandError)
    end
  end

  context 'the :aggregate argument' do
    before do
      @smalls = 'mock-redis-test:zinterstore:smalls'
      @bigs   = 'mock-redis-test:zinterstore:bigs'

      @redises.zadd(@smalls, 1, 'bert')
      @redises.zadd(@smalls, 2, 'ernie')
      @redises.zadd(@bigs, 100, 'bert')
      @redises.zadd(@bigs, 200, 'ernie')
    end

    it 'aggregates scores with min when :aggregate => :min is specified' do
      @redises.zinterstore(@dest, [@bigs, @smalls], :aggregate => :min)
      expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
        [['bert', 1.0], ['ernie', 2.0]]
      )
    end

    it 'aggregates scores with max when :aggregate => :max is specified' do
      @redises.zinterstore(@dest, [@bigs, @smalls], :aggregate => :max)
      expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
        [['bert', 100.0], ['ernie', 200.0]]
      )
    end

    it "allows 'min', 'MIN', etc. as aliases for :min" do
      @redises.zinterstore(@dest, [@bigs, @smalls], :aggregate => 'min')
      expect(@redises.zscore(@dest, 'bert')).to eq(1.0)

      @redises.zinterstore(@dest, [@bigs, @smalls], :aggregate => 'MIN')
      expect(@redises.zscore(@dest, 'bert')).to eq(1.0)
    end

    it 'raises an error for unknown aggregation function' do
      expect do
        @redises.zinterstore(@dest, [@bigs, @smalls], :aggregate => :mix)
      end.to raise_error(Redis::CommandError)
    end
  end
end
