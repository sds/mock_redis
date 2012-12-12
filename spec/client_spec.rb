require 'spec_helper'

describe 'client' do
  context '#reconnect' do
    it 'reconnects' do
      redis = MockRedis.new
      redis.reconnect.should == redis
    end
  end
end
