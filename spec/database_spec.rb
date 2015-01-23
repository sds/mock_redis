require 'spec_helper'

describe MockRedis::Database do
  context 'Initialized' do
    let(:redis){ double }
    let(:db) { MockRedis::Database.new redis }

    it 'provides access to redis object' do
      expect(db.redis).to eq(redis)
    end

    it 'has empty expiration keys' do
      expect(db.expire_times).to be_empty
    end

    it 'Has empty data' do
      expect(db.data).to be_empty
    end
  end
end
