require 'spec_helper'

describe 'client' do
  context '#reconnect' do
    it 'reconnects' do
      redis = MockRedis.new
      redis.reconnect.should == redis
    end
  end

  context '#connect' do
    it 'connects' do
      redis = MockRedis.new
      redis.connect.should == redis
    end
  end
end
