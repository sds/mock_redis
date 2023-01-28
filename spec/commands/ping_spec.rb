require 'spec_helper'

RSpec.describe '#ping' do
  it 'returns "PONG" with no arguments' do
    expect(@redises.ping).to eq('PONG')
  end

  it 'returns the argument' do
    expect(@redises.ping('HELLO')).to eq('HELLO')
  end
end
