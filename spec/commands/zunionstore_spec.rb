require 'spec_helper'

RSpec.describe '#zunionstore(destination, keys, '\
               '[:weights => [w,w,], [:aggregate => :sum|:min|:max])' do
  before do
    @set1 = 'mock-redis-test:zunionstore1'
    @set2 = 'mock-redis-test:zunionstore2'
    @set3 = 'mock-redis-test:zunionstore3'
    @dest = 'mock-redis-test:zunionstoredest'

    @redises.zadd(@set1, 1, 'one')

    @redises.zadd(@set2, 1, 'one')
    @redises.zadd(@set2, 2, 'two')

    @redises.zadd(@set3, 1, 'one')
    @redises.zadd(@set3, 2, 'two')
    @redises.zadd(@set3, 3, 'three')
  end

  it 'returns the number of elements in the new set' do
    expect(@redises.zunionstore(@dest, [@set1, @set2, @set3])).to eq(3)
  end

  it "sums the members' scores by default" do
    @redises.zunionstore(@dest, [@set1, @set2, @set3])
    expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
      [['one', 3.0], ['three', 3.0], ['two', 4.0]]
    )
  end

  it 'removes existing elements in destination' do
    @redises.zadd(@dest, 10, 'ten')

    @redises.zunionstore(@dest, [@set1])
    expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
      [['one', 1.0]]
    )
  end

  it 'raises an error if keys is empty' do
    expect do
      @redises.zunionstore(@dest, [])
    end.to raise_error(Redis::CommandError)
  end

  context 'when used with a set' do
    before do
      @set4 = 'mock-redis-test:zunionstore4'

      @redises.sadd(@set4, 'two')
      @redises.sadd(@set4, 'three')
      @redises.sadd(@set4, 'four')
    end

    it 'returns the number of elements in the new set' do
      expect(@redises.zunionstore(@dest, [@set3, @set4])).to eq(4)
    end

    it 'sums the scores, substituting 1.0 for set values' do
      @redises.zunionstore(@dest, [@set3, @set4])
      expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
        [['four', 1.0], ['one', 1.0], ['two', 3.0], ['three', 4.0]]
      )
    end
  end

  context 'when used with a non-coercible structure' do
    before do
      @non_set = 'mock-redis-test:zunionstore4'

      @redises.set(@non_set, 'one')
    end
    it 'raises an error for wrong value type' do
      expect do
        @redises.zunionstore(@dest, [@set1, @non_set])
      end.to raise_error(Redis::CommandError)
    end
  end

  context 'the :weights argument' do
    it 'multiplies the scores by the weights while aggregating' do
      @redises.zunionstore(@dest, [@set1, @set2, @set3], :weights => [2, 3, 5])
      expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
        [['one', 10.0], ['three', 15.0], ['two', 16.0]]
      )
    end

    it 'raises an error if the number of weights != the number of keys' do
      expect do
        @redises.zunionstore(@dest, [@set1, @set2, @set3], :weights => [1, 2])
      end.to raise_error(Redis::CommandError)
    end
  end

  context 'the :aggregate argument' do
    before do
      @smalls = 'mock-redis-test:zunionstore:smalls'
      @bigs   = 'mock-redis-test:zunionstore:bigs'

      @redises.zadd(@smalls, 1, 'bert')
      @redises.zadd(@smalls, 2, 'ernie')
      @redises.zadd(@bigs, 100, 'bert')
      @redises.zadd(@bigs, 200, 'ernie')
    end

    it 'aggregates scores with min when :aggregate => :min is specified' do
      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :min)
      expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
        [['bert', 1.0], ['ernie', 2.0]]
      )
    end

    it 'aggregates scores with max when :aggregate => :max is specified' do
      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :max)
      expect(@redises.zrange(@dest, 0, -1, :with_scores => true)).to eq(
        [['bert', 100.0], ['ernie', 200.0]]
      )
    end

    it 'ignores scores for missing members' do
      @redises.zadd(@smalls, 3, 'grover')
      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :min)
      expect(@redises.zscore(@dest, 'grover')).to eq(3.0)

      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :max)
      expect(@redises.zscore(@dest, 'grover')).to eq(3.0)
    end

    it "allows 'min', 'MIN', etc. as aliases for :min" do
      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => 'min')
      expect(@redises.zscore(@dest, 'bert')).to eq(1.0)

      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => 'MIN')
      expect(@redises.zscore(@dest, 'bert')).to eq(1.0)
    end

    it 'raises an error for unknown aggregation function' do
      expect do
        @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :mix)
      end.to raise_error(Redis::CommandError)
    end
  end
end
