require 'spec_helper'

RSpec.describe '#bgsave [mock only]' do
  it 'just returns a canned string' do
    expect(@redises.mock.bgsave).to match(/saving/)
  end
end
