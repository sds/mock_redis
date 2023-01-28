require 'spec_helper'

RSpec.describe '#mapped_hmget(key, *fields)' do
  before do
    @key = 'mock-redis-test:mapped_hmget'
    @redises.hmset(@key, 'k1', 'v1', 'k2', 'v2')
  end

  it 'returns values stored at key' do
    expect(@redises.mapped_hmget(@key, 'k1', 'k2')).to eq({ 'k1' => 'v1', 'k2' => 'v2' })
  end

  it 'returns nils for missing fields' do
    expect(@redises.mapped_hmget(@key, 'k1', 'mock-redis-test:nonesuch')).
      to eq({ 'k1' => 'v1', 'mock-redis-test:nonesuch' => nil })
  end

  it 'treats an array as the first key' do
    expect(@redises.mapped_hmget(@key, %w[k1 k2])).to eq({ %w[k1 k2] => 'v1' })
  end

  it 'raises an error if given no fields' do
    expect do
      @redises.mapped_hmget(@key)
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a hash-only command'
end
