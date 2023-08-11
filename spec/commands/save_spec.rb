require 'spec_helper'

RSpec.describe '#save' do
  it "responds with 'OK'" do
    expect(@redises.save).to eq('OK')
  end
end
