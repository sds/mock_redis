require 'spec_helper'

RSpec.describe '#auth(password) [mock only]' do
  it "just returns 'OK'" do
    expect(@redises.mock.auth('foo')).to eq('OK')
  end
end
