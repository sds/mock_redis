require 'spec_helper'

describe '#pipelined' do
  it 'yields to its block' do
    res = false
    @redises.pipelined do
      res = true
    end
    res.should == true
  end
end
