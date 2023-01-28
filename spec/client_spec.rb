require 'spec_helper'

RSpec.describe 'client' do
  context '#reconnect' do
    it 'reconnects' do
      redis = MockRedis.new
      expect(redis.reconnect).to eq(redis)
    end
  end

  context '#connect' do
    it 'connects' do
      redis = MockRedis.new
      expect(redis.connect).to eq(redis)
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

  context '#with' do
    it 'supports with' do
      redis = MockRedis.new
      expect(redis.with { |c| c.set('key', 'value') }).to eq('OK')
    end
  end
end
