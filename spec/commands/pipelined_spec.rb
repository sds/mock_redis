require 'spec_helper'

describe '#pipelined' do
  it "should yield to it's block'" do
    res = false
    @redises.pipelined do
      res = true
    end
    res.should == true
  end
end
