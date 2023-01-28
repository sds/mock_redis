require 'spec_helper'

RSpec.describe '#blpop(key [, key, ...,], timeout)' do
  before do
    @list1 = 'mock-redis-test:blpop1'
    @list2 = 'mock-redis-test:blpop2'

    @redises.rpush(@list1, 'one')
    @redises.rpush(@list1, 'two')
    @redises.rpush(@list2, 'ten')
    @redises.rpush(@list2, 'eleven')
  end

  it 'returns [first-nonempty-list, popped-value]' do
    expect(@redises.blpop(@list1, @list2)).to eq([@list1, 'one'])
  end

  it 'pops that value off the list' do
    @redises.blpop(@list1, @list2)
    @redises.blpop(@list1, @list2)

    expect(@redises.blpop(@list1, @list2)).to eq([@list2, 'ten'])
  end

  it 'ignores empty keys' do
    expect(@redises.blpop('mock-redis-test:not-here', @list1)).to eq(
      [@list1, 'one']
    )
  end

  it 'raises an error on negative timeout' do
    expect do
      @redises.blpop(@list1, @list2, :timeout => -1)
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a list-only command'

  context '[mock only]' do
    it 'ignores positive timeouts and returns nil' do
      expect(@redises.mock.blpop('mock-redis-test:not-here', :timeout => 1)).to be_nil
    end

    it 'ignores positive legacy timeouts and returns nil' do
      expect(@redises.mock.blpop('mock-redis-test:not-here', 1)).to be_nil
    end

    it 'raises WouldBlock on zero timeout (no blocking in the mock)' do
      expect do
        @redises.mock.blpop('mock-redis-test:not-here', :timeout => 0)
      end.to raise_error(MockRedis::WouldBlock)
    end
  end
end
