require 'spec_helper'

RSpec.describe MockRedis do
  let(:url) { 'redis://127.0.0.1:6379/1' }

  describe '.new' do
    subject { MockRedis.new(:url => url) }

    it 'correctly parses options' do
      expect(subject.host).to eq('127.0.0.1')
      expect(subject.port).to eq(6379)
      expect(subject.db).to eq(1)
    end

    its(:id) { should == url }

    its(:location) { should == url }
  end

  describe '.connect' do
    let(:url) { 'redis://127.0.0.1:6379/0' }
    subject { MockRedis.connect(:url => url) }

    it 'correctly parses options' do
      expect(subject.host).to eq('127.0.0.1')
      expect(subject.port).to eq(6379)
      expect(subject.db).to eq(0)
    end

    its(:id) { should == url }
  end

  describe 'Injecting a time class' do
    describe '.options' do
      let(:time_stub) { double 'Time' }
      let(:options)   { { :time_class => time_stub } }

      it 'defaults to Time' do
        mock_redis = MockRedis.new

        expect(mock_redis.options[:time_class]).to eq(Time)
      end

      it 'has a configurable Time class' do
        mock_redis = MockRedis.new(options)

        expect(mock_redis.options[:time_class]).to eq(time_stub)
      end
    end

    describe '.now' do
      let(:time_stub) { double 'Time', :now => Time.new(2019, 1, 2, 3, 4, 6, '+00:00') }
      let(:options)   { { :time_class => time_stub } }

      subject { MockRedis.new(options) }

      its(:now) { should == [1_546_398_246, 0] }
    end

    describe '.time' do
      let(:time_stub) { double 'Time', :now => Time.new(2019, 1, 2, 3, 4, 6, '+00:00') }
      let(:options)   { { :time_class => time_stub } }

      subject { MockRedis.new(options) }

      its(:time) { should == [1_546_398_246, 0] }
    end

    describe '.expireat' do
      let(:time_at)   { 'expireat' }
      let(:time_stub) { double 'Time' }
      let(:options)   { { :time_class => time_stub } }
      let(:timestamp) { 123_456 }

      subject { MockRedis.new(options) }

      it 'Forwards time_at to the time_class' do
        expect(time_stub).to receive(:at).with(timestamp).and_return(time_at)

        expect(subject.time_at(timestamp)).to eq(time_at)
      end
    end
  end

  describe 'supplying a logger' do
    it 'logs redis commands' do
      logger = double('Logger', debug?: true, debug: nil)
      mock_redis = MockRedis.new(logger: logger)
      expect(logger).to receive(:debug).with(/command=HMGET args="hash" "key1" "key2"/)
      mock_redis.hmget('hash', 'key1', 'key2')
    end
  end
end
