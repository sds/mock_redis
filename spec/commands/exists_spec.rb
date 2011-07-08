require 'spec_helper'

describe "#exists(key)" do
  before { @key = 'mock-redis-test:45794' }

  it "returns false for keys that do not exist" do
    @redises.exists(@key).should be_false
  end

  it "returns true for keys that do exist" do
    @redises.set(@key, 1)
    @redises.exists(@key).should be_true
  end
end
