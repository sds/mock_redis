require 'spec_helper'

describe '#lindex(key, index)' do
  before { @key = 'mock-redis-test:69312' }

  it "gets an element from the list by its index" do
    @redises.lpush(@key, 20)
    @redises.lpush(@key, 10)

    @redises.lindex(@key, 0).should == "10"
    @redises.lindex(@key, 1).should == "20"
  end

  it "treats negative indices as coming from the right" do
    @redises.lpush(@key, 20)
    @redises.lpush(@key, 10)

    @redises.lindex(@key, -1).should == "20"
    @redises.lindex(@key, -2).should == "10"
  end

  it "returns nil if the index is too large (and positive)" do
    @redises.lpush(@key, 20)

    @redises.lindex(@key, 100).should be_nil
  end

  it "returns nil if the index is too large (and negative)" do
    @redises.lpush(@key, 20)

    @redises.lindex(@key, -100).should be_nil
  end

  it "returns nil for nonexistent values" do
    @redises.lindex(@key, 0).should be_nil
  end

  it "raises an error for non-list values" do
    @redises.set(@key, 'string value')

    lambda do
      @redises.lindex(@key, 0)
    end.should raise_error(RuntimeError)
  end
end
