require 'spec_helper'

describe '#watch(key)' do
  it "returns 'OK'" do
    @redises.watch('mock-redis-test').should == 'OK'
  end

  it 'EXECs its MULTI on successes' do
    @redises.watch 'foo' do
      @redises.multi do |multi|
        multi.set 'bar', 'baz'
      end
    end
    @redises.get('bar').should eq('baz')
  end
end
