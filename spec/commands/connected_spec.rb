require 'spec_helper'

describe "#connected? [mock only]" do
  it "returns true" do
    @redises.mock.connected?.should be_true
  end
end
