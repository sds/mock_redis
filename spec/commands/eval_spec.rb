require 'spec_helper'

RSpec.describe '#eval(*)' do
  it 'returns nothing' do
    expect(@redises.eval('return nil')).to be_nil
  end
end
