require 'spec_helper'

RSpec.describe '#brpoplpush(source, destination, timeout)' do
  let(:default_error) { ArgumentError }

  before do
    @list1 = 'mock-redis-test:brpoplpush1'
    @list2 = 'mock-redis-test:brpoplpush2'

    @redises.rpush(@list1, 'A')
    @redises.rpush(@list1, 'B')

    @redises.rpush(@list2, 'alpha')
    @redises.rpush(@list2, 'beta')
  end

  it 'takes the last element of source and prepends it to destination' do
    @redises.brpoplpush(@list1, @list2)
    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[A])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[B alpha beta])
  end

  it 'returns the moved element' do
    expect(@redises.brpoplpush(@list1, @list2)).to eq('B')
  end

  it 'raises an error on negative timeout' do
    expect do
      @redises.brpoplpush(@list1, @list2, :timeout => -1)
    end.to raise_error(ArgumentError)
  end

  let(:default_error) { Redis::WrongTypeError }
  it_should_behave_like 'a list-only command'

  context '[mock only]' do
    it 'ignores positive timeouts and returns nil' do
      expect(@redises.mock.brpoplpush('mock-redis-test:not-here', @list1, :timeout => 1)).
        to be_nil
    end

    it 'raises error if there is extra argument' do
      expect do
        @redises.mock.brpoplpush('mock-redis-test:not-here', @list1, 1)
      end.to raise_error(ArgumentError)
    end

    it 'raises WouldBlock on zero timeout (no blocking in the mock)' do
      expect do
        @redises.mock.brpoplpush('mock-redis-test:not-here', @list1, :timeout => 0)
      end.to raise_error(MockRedis::WouldBlock)
    end
  end
end
