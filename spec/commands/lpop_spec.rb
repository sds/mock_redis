require 'spec_helper'

describe '#lpop' do
  before { @key = 'mock-redis-test:65374' }

  it "returns and removes the first element of a list" do
    @redises.lpush(@key, 1)
    @redises.lpush(@key, 2)

    @redises.lpop(@key).should == "2"

    @redises.llen(@key).should == 1
  end

  it "returns nil if the list is empty" do
    @redises.lpush(@key, 'foo')
    @redises.lpop(@key)

    @redises.lpop(@key).should be_nil
  end

  it "returns nil for nonexistent values" do
    @redises.lpop(@key).should be_nil
  end

  it "raises an error for non-list values" do
    @redises.set(@key, 'string value')

    lambda do
      @redises.lpop(@key)
    end.should raise_error(RuntimeError)
  end
end
