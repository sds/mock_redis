require 'spec_helper'

RSpec.describe '#connected? [mock only]' do
  it 'returns true' do
    expect(@redises.mock.connected?).to eq(true)
  end
end
