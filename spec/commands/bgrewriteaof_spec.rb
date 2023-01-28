require 'spec_helper'

RSpec.describe '#bgrewriteaof [mock only]' do
  it 'just returns a canned string' do
    expect(@redises.mock.bgrewriteaof).to match(/append/)
  end
end
