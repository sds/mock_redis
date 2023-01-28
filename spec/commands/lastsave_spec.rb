require 'spec_helper'

RSpec.describe '#lastsave [mock only]' do
  # can't test against both since it's timing-dependent
  it 'returns a Unix time' do
    expect(@redises.mock.lastsave.to_s).to match(/^\d+$/)
  end
end
