require 'spec_helper'

RSpec.describe '#blmove(source, destination, wherefrom, whereto, timeout)' do
  before do
    @list1 = 'mock-redis-test:blmove-list1'
    @list2 = 'mock-redis-test:blmove-list2'

    @redises.lpush(@list1, 'b')
    @redises.lpush(@list1, 'a')

    @redises.lpush(@list2, 'y')
    @redises.lpush(@list2, 'x')
  end

  it 'returns the value moved' do
    expect(@redises.blmove(@list1, @list2, 'left', 'right')).to eq('a')
  end

  it 'takes the first element of source and appends it to destination' do
    @redises.blmove(@list1, @list2, 'left', 'right')

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[b])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[x y a])
  end

  it 'raises an error on negative timeout' do
    expect do
      @redises.blmove(@list1, @list2, 'left', 'right', :timeout => -1)
    end.to raise_error(ArgumentError)
  end

  let(:default_error) { RedisMultiplexer::MismatchedResponse }
  it_should_behave_like 'a list-only command'

  context '[mock only]' do
    it 'ignores positive timeouts and returns nil' do
      expect(
        @redises.mock.blmove(
          'mock-redis-test:not-here',
          @list1,
          'left',
          'right',
          :timeout => 1
        )
      ).to be_nil
    end

    it 'ignores positive legacy timeouts and returns nil' do
      expect(@redises.mock.blmove('mock-redis-test:not-here', @list1, 'left', 'right', 1)).
        to be_nil
    end

    it 'raises WouldBlock on zero timeout (no blocking in the mock)' do
      expect do
        @redises.mock.blmove('mock-redis-test:not-here', @list1, 'left', 'right', :timeout => 0)
      end.to raise_error(MockRedis::WouldBlock)
    end
  end
end
