require 'spec_helper'

RSpec.describe '#dump(key)' do
  before do
    @key = 'mock-redis-test:45794'
    # These are mock-only, since our dump/restore implementations
    # aren't compatible with real redis.
    @mock = @redises.mock
  end

  it 'returns nil for keys that do not exist' do
    expect(@mock.dump(@key)).to be_nil
  end

  it 'returns a serialized value for keys that do exist' do
    @mock.set(@key, '2')
    expect(@mock.dump(@key)).to eq(Marshal.dump('2'))
  end
end
