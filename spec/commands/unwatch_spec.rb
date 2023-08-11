require 'spec_helper'

RSpec.describe '#unwatch' do
  it "responds with 'OK'" do
    expect(@redises.unwatch).to eq('OK')
  end
end
