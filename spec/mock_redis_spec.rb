require 'spec_helper'

describe MockRedis do
  let(:url) { 'redis://127.0.0.1:6379/1' }

  describe '.new' do
    subject { MockRedis.new(:url => url) }

    it 'correctly parses options' do
      subject.host.should == '127.0.0.1'
      subject.port.should == 6379
      subject.db.should == 1
    end

    its(:id) { should == url }

    its(:location) { should == url }
  end

  describe '.connect' do
    let(:url) { 'redis://127.0.0.1:6379/0' }
    subject { MockRedis.connect(:url => url) }

    it 'correctly parses options' do
      subject.host.should == '127.0.0.1'
      subject.port.should == 6379
      subject.db.should == 0
    end

    its(:id) { should == url }
  end
end
