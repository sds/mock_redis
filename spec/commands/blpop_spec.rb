require 'spec_helper'

describe '#blpop(key [, key, ...,], timeout)' do
  before do
    @list1 = 'mock-redis-test:blpop1'
    @list2 = 'mock-redis-test:blpop2'

    @redises.lpush(@list1, 'one')
    @redises.lpush(@list2, 'two')
  end

  it "returns [first-nonempty-list, popped-value]" do
    @redises.blpop(@list1, @list2, 1).should == [@list1, 'one']
  end

  it "pops that value off the list" do
    @redises.blpop(@list1, @list2, 1)
    @redises.blpop(@list1, @list2, 1).should == [@list2, 'two']
  end

  it "ignores empty keys" do
    @redises.blpop('mock-redis-test:not-here', @list1, 1).should ==
      [@list1, 'one']
  end

  it "errors out on non-list keys" do
    @redises.set(@list1, 'a string')
    lambda do
      @redises.blpop(@list1, @list2, 1)
    end.should raise_error(RuntimeError)
  end

  it "raises an error on non-integer timeout" do
    lambda do
      @redises.blpop(@list1, @list2, 0.5)
    end.should raise_error(RuntimeError)
  end

  it "raises an error on negative timeout" do
    lambda do
      @redises.blpop(@list1, @list2, -1)
    end.should raise_error(RuntimeError)
  end

  context "[mock only]" do
    it "ignores positive timeouts and returns nil" do
      @redises.mock.blpop('mock-redis-test:not-here', 1).should be_nil
    end

    it "raises WouldBlock on zero timeout (no blocking in the mock)" do
      lambda do
        @redises.mock.blpop('mock-redis-test:not-here', 0)
      end.should raise_error(MockRedis::WouldBlock)
    end
  end
end
