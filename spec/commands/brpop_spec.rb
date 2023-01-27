require 'spec_helper'

RSpec.describe '#brpop(key [, key, ...,], timeout)' do
  before do
    @list1 = 'mock-redis-test:brpop1'
    @list2 = 'mock-redis-test:brpop2'

    @redises.rpush(@list1, 'one')
    @redises.rpush(@list1, 'two')

    @redises.rpush(@list2, 'ten')
  end

  it 'returns [first-nonempty-list, popped-value]' do
    expect(@redises.brpop(@list1, @list2)).to eq([@list1, 'two'])
  end

  it 'pops that value off the list' do
    @redises.brpop(@list1, @list2)
    @redises.brpop(@list1, @list2)
    expect(@redises.brpop(@list1, @list2)).to eq([@list2, 'ten'])
  end

  it 'ignores empty keys' do
    expect(@redises.brpop('mock-redis-test:not-here', @list1)).to eq(
      [@list1, 'two']
    )
  end

  # TODO: Not sure how redis-rb is handling this but they're not raising an error
  # it 'raises an error on subsecond timeouts' do
  #   lambda do
  #     @redises.brpop(@list1, @list2, :timeout => 0.5)
  #   end.should raise_error(Redis::CommandError)
  # end

  it 'raises an error on negative timeout' do
    expect do
      @redises.brpop(@list1, @list2, :timeout => -1)
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a list-only command'

  context '[mock only]' do
    it 'ignores positive timeouts and returns nil' do
      expect(@redises.mock.brpop('mock-redis-test:not-here', :timeout => 1)).to be_nil
    end

    it 'ignores positive legacy timeouts and returns nil' do
      expect(@redises.mock.brpop('mock-redis-test:not-here', 1)).to be_nil
    end

    it 'raises WouldBlock on zero timeout (no blocking in the mock)' do
      expect do
        @redises.mock.brpop('mock-redis-test:not-here', :timeout => 0)
      end.to raise_error(MockRedis::WouldBlock)
    end
  end
end
