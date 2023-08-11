require 'spec_helper'

RSpec.describe '#dbsize [mock only]' do
  # mock only since we can't guarantee that the real Redis is empty
  before { @mock = @redises.mock }

  it 'returns 0 for an empty DB' do
    expect(@mock.dbsize).to eq(0)
  end

  it 'returns the number of keys in the DB' do
    @mock.set('foo', 1)
    @mock.lpush('bar', 2)
    @mock.hset('baz', 3, 4)

    expect(@mock.dbsize).to eq(3)
  end
end
