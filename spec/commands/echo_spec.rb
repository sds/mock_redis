require 'spec_helper'

RSpec.describe '#echo(str)' do
  it 'returns its argument' do
    expect(@redises.echo('foo')).to eq('foo')
  end

  it 'stringifies its argument' do
    expect(@redises.echo(1)).to eq('1')
  end
end
