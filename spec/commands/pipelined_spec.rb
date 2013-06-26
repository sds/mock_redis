require 'spec_helper'

describe '#pipelined' do
  it 'yields to its block' do
    res = false
    @redises.pipelined do
      res = true
    end
    res.should == true
  end

  it "returns results of pipelined operations" do
    @redises.set "hello", "world"
    @redises.set "foo", "bar"

    results = @redises.pipelined do |redis|
      redis.get "hello"
      redis.get "foo"
    end

    results.should == ["world", "bar"]
  end
end
