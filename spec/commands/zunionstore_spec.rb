require 'spec_helper'

describe "#zunionstore(destination, keys, [:weights => [w,w,], [:aggregate => :sum|:min|:max])" do
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

  it "returns the number of elements in the new set" do
    @redises.zunionstore(@dest, [@set1, @set2, @set3]).should == 3
  end

  it "sums the members' scores by default" do
    @redises.zunionstore(@dest, [@set1, @set2, @set3])
    @redises.zrange(@dest, 0, -1, :with_scores => true).should ==
      %w[one 3 three 3 two 4]
  end

  it "raises an error if keys is empty" do
    lambda do
      @redises.zunionstore(@dest, [])
    end.should raise_error(RuntimeError)
  end

  context "the :weights argument" do
    it "multiplies the scores by the weights while aggregating" do
      @redises.zunionstore(@dest, [@set1, @set2, @set3], :weights => [2, 3, 5])
      @redises.zrange(@dest, 0, -1, :with_scores => true).should ==
        %w[one 10 three 15 two 16]
    end

    it "raises an error if the number of weights != the number of keys" do
      lambda do
        @redises.zunionstore(@dest, [@set1, @set2, @set3], :weights => [1,2])
      end.should raise_error(RuntimeError)
    end
  end

  context "the :aggregate argument" do
    before do
      @smalls = 'mock-redis-test:zunionstore:smalls'
      @bigs   = 'mock-redis-test:zunionstore:bigs'

      @redises.zadd(@smalls, 1, 'bert')
      @redises.zadd(@smalls, 2, 'ernie')
      @redises.zadd(@bigs, 100, 'bert')
      @redises.zadd(@bigs, 200, 'ernie')
    end

    it "aggregates scores with min when :aggregate => :min is specified" do
      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :min)
      @redises.zrange(@dest, 0, -1, :with_scores => true).should ==
        %w[bert 1 ernie 2]
    end

    it "aggregates scores with max when :aggregate => :max is specified" do
      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :max)
      @redises.zrange(@dest, 0, -1, :with_scores => true).should ==
        %w[bert 100 ernie 200]
    end

    it "ignores scores for missing members" do
      @redises.zadd(@smalls, 3, 'grover')
      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :min)
      @redises.zscore(@dest, 'grover').should == '3'

      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :max)
      @redises.zscore(@dest, 'grover').should == '3'
    end

    it "allows 'min', 'MIN', etc. as aliases for :min" do
      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => 'min')
      @redises.zscore(@dest, 'bert').should == '1'

      @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => 'MIN')
      @redises.zscore(@dest, 'bert').should == '1'
    end

    it "raises an error for unknown aggregation function" do
      lambda do
        @redises.zunionstore(@dest, [@bigs, @smalls], :aggregate => :mix)
      end.should raise_error(RuntimeError)
    end
  end
end
