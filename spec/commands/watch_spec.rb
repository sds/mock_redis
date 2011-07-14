require 'spec_helper'

describe '#watch(key)' do
  it "responds with 'OK'" do
    @redises.watch('mock-redis-test').should == 'OK'
  end
end
