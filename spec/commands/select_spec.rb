require 'spec_helper'

describe "#select(db)" do
  before { @key = 'mock-redis-test:select' }

  it "returns 'OK'" do
    @redises.select(0).should == 'OK'
  end

  it "treats '0' and 0 the same" do
    @redises.select('0')
    @redises.set(@key, 'foo')
    @redises.select(0)
    @redises.get(@key).should == 'foo'
  end

  it "switches databases" do
    @redises.select(0)
    @redises.set(@key, 'foo')

    @redises.select(1)
    @redises.get(@key).should be_nil

    @redises.select(0)
    @redises.get(@key).should == 'foo'
  end

  context "databases' ttl" do
    # Time dependence introduces a bit of nondeterminism here
    before do
      @now = Time.now
      Time.stub!(:now).and_return(@now)

      @redises.select(0)
      @redises.set(@key, 1)
      @redises.expire(@key, 100)

      @redises.select(1)
      @redises.set(@key, 2)
      @redises.expire(@key, 200)
    end

    it "keeps expire times per-db" do
      @redises.select(0)
      @redises.ttl(@key).should == 100

      @redises.select(1)
      @redises.ttl(@key).should == 200
    end
  end
end
