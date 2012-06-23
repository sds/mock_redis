require 'spec_helper'

describe MockRedis::Database do
  before do
    # that actually returns MockRedis::Database object
    @mock = MockRedis.new
  end

  it "should have a reference to a MockRedis object" do
    @mock.client.class.should == MockRedis
  end
  
end