require 'spec_helper'

describe '#info [mock only]' do
  before { @info = @redises.mock.info }

  it "responds with a config hash" do
    @info.should be_a(Hash)
  end

  it "has some data in it" do
    @info.keys.length.should > 0
  end
end
