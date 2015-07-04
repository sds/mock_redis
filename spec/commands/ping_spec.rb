require 'spec_helper'

describe '#ping' do
  it "returns 'PONG'" do
    @redises.ping.should == 'PONG'
  end
end
