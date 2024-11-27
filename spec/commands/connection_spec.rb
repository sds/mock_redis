require 'spec_helper'

RSpec.describe '#connection' do
  let(:redis) { @redises.mock }

  it 'returns the correct values' do
    expect(redis.connection).to eq(
      {
        :host => 'localhost',
        :port => 6379,
        :db => 0,
        :id => 'redis://localhost:6379/0',
        :location => 'localhost:6379'
      }
    )
  end
end
