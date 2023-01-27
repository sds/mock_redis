require 'spec_helper'

RSpec.describe '#disconnect [mock only]' do
  it 'returns nil' do
    expect(@redises.mock.disconnect).to be_nil
  end
end
