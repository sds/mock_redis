require 'spec_helper'

describe MockRedis do

  context "with passed options" do
    before do
      @mock = MockRedis.new(:url => "redis://127.0.0.1:6379/1")
    end

    it "should correctly parse options" do
      @mock.host.should == "127.0.0.1"
      @mock.port.should == 6379
      @mock.db.should == 1
    end

    it "should have an id equal to redis url" do
      @mock.id.should == "redis://127.0.0.1:6379/1"
    end
  end

end
