require 'spec_helper'

describe '#hset(key, field)' do
  before do
    @key = 'mock-redis-test:hset'
  end

  it 'returns true' do
    @redises.hset(@key, 'k1', 'v1').should == true
  end

  it 'creates a hash there is no such field' do
    @redises.hset(@key, 'k1', 'v1')
    @redises.hget(@key, 'k1').should == 'v1'
  end

  it 'stores values as strings' do
    @redises.hset(@key, 'num', 1)
    @redises.hget(@key, 'num').should == '1'
  end

  it 'stores fields as strings' do
    @redises.hset(@key, 1, 'one')
    @redises.hget(@key, '1').should == 'one'
  end

  it_should_behave_like 'a hash-only command'
end
