require 'spec_helper'

RSpec.describe '#evalsha(*)' do
  let(:script) { 'return nil' }
  let(:script_digest) { Digest::SHA1.hexdigest(script) }

  it 'returns nothing' do
    expect(@redises.evalsha(script_digest)).to be_nil
  end
end
