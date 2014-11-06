require 'spec_helper'

describe '#set(key, value)' do
  it "responds with 'OK'" do
    @redises.set('mock-redis-test', 1).should == 'OK'
  end

  context 'options' do
    it 'raises an error for EX seconds = 0' do
      expect do
        @redises.set('mock-redis-test', 1, ex: 0)
      end.to raise_error(Redis::CommandError, 'ERR invalid expire time in set')
    end

    it 'raises an error for PX milliseconds = 0' do
      expect do
        @redises.set('mock-redis-test', 1, px: 0)
      end.to raise_error(Redis::CommandError, 'ERR invalid expire time in set')
    end

    it 'accepts NX' do
      key = 'mock-redis-test'
      @redises.del(key)
      @redises.set(key, 1, nx: true).should == true
      @redises.set(key, 1, nx: true).should == false
    end

    it 'accepts XX' do
      key = 'mock-redis-test'
      @redises.del(key)
      @redises.set(key, 1, xx: true).should == false
      @redises.set(key, 1).should == 'OK'
      @redises.set(key, 1, xx: true).should == true
    end

    context '[mock only]' do
      before(:all) do
        @mock = @redises.mock
      end

      before do
        @now = Time.now
        Time.stub(:now).and_return(@now)
      end

      it 'accepts EX seconds' do
        key = 'mock-redis-test'
        @mock.set(key, 1, ex: 1).should == 'OK'
        @mock.get(key).should_not be_nil
        Time.stub(:now).and_return(@now + 2)
        @mock.get(key).should be_nil
      end

      it 'accepts PX milliseconds' do
        key = 'mock-redis-test'
        @mock.set(key, 1, px: 1000).should == 'OK'
        @mock.get(key).should_not be_nil
        Time.stub(:now).and_return(@now + 2)
        @mock.get(key).should be_nil
      end
    end
  end
end
