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

  context '#disconnect!' do
    it 'responds to disconnect!' do
      expect(MockRedis.new).to respond_to(:disconnect!)
    end
  end

  context '#close' do
    it 'responds to close' do
      expect(MockRedis.new).to respond_to(:close)
    end
  end
end
