require 'spec_helper'

describe '#del(key [, key, ...])' do
  it 'returns the number of keys deleted' do
    @redises.set('mock-redis-test:1', 1)
    @redises.set('mock-redis-test:2', 1)

    @redises.del(
      'mock-redis-test:1',
      'mock-redis-test:2',
      'mock-redis-test:other').should == 2
  end

  it 'actually removes the key' do
    @redises.set('mock-redis-test:1', 1)
    @redises.del('mock-redis-test:1')

    @redises.get('mock-redis-test:1').should be_nil
  end

  it 'accepts an array of keys' do
    @redises.set('mock-redis-test:1', 1)
    @redises.set('mock-redis-test:2', 2)

    @redises.del(%w[mock-redis-test:1 mock-redis-test:2])

    @redises.get('mock-redis-test:1').should be_nil
    @redises.get('mock-redis-test:2').should be_nil
  end

  it 'raises an error if an empty array is given' do
    expect { @redises.del [] }.to raise_error Redis::CommandError
  end
end
