require 'spec_helper'

RSpec.describe '#mapped_mget(*keys)' do
  before do
    @key1 = 'mock-redis-test:a'
    @key2 = 'mock-redis-test:b'
    @key3 = 'mock-redis-test:c'

    @redises.set(@key1, '1')
    @redises.set(@key2, '2')
  end

  it 'returns a hash' do
    expect(@redises.mapped_mget(@key1, @key2, @key3)).to eq(
      @key1 => '1',
      @key2 => '2',
      @key3 => nil
    )
  end

  it 'returns a hash even when no matches' do
    expect(@redises.mapped_mget('qwer')).to eq('qwer' => nil)
  end
end
