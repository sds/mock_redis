require 'spec_helper'

describe '#set(key, value)' do
  it "responds with 'OK'" do
    @redises.set('mock-redis-test', 1).should == 'OK'
  end
end
