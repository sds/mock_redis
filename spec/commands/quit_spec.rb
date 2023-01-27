require 'spec_helper'

RSpec.describe '#quit' do
  it "responds with 'OK'" do
    expect(@redises.quit).to eq('OK')
  end
end
