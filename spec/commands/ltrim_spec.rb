require 'spec_helper'

RSpec.describe '#ltrim(key, start, stop)' do
  before do
    @key = 'mock-redis-test:22310'

    %w[v0 v1 v2 v3 v4].reverse_each { |v| @redises.lpush(@key, v) }
  end

  it "returns 'OK'" do
    expect(@redises.ltrim(@key, 1, 3)).to eq('OK')
  end

  it 'trims the list to include only the specified elements' do
    @redises.ltrim(@key, 1, 3)
    expect(@redises.lrange(@key, 0, -1)).to eq(%w[v1 v2 v3])
  end

  it 'trims the list when start and stop are strings' do
    @redises.ltrim(@key, '1', '3')
    expect(@redises.lrange(@key, 0, -1)).to eq(%w[v1 v2 v3])
  end

  it 'trims the list to include only the specified elements (negative indices)' do
    @redises.ltrim(@key, -2, -1)
    expect(@redises.lrange(@key, 0, -1)).to eq(%w[v3 v4])
  end

  it 'trims the list to include only the specified elements (out of range negative indices)' do
    @redises.ltrim(@key, -10, -2)
    expect(@redises.lrange(@key, 0, -1)).to eq(%w[v0 v1 v2 v3])
  end

  it 'does not crash on overly-large indices' do
    @redises.ltrim(@key, 100, 200)
    expect(@redises.lrange(@key, 0, -1)).to eq(%w[])
  end

  it 'removes empty lists' do
    @redises.ltrim(@key, 1, 0)
    expect(@redises.get(@key)).to be_nil
  end

  it_should_behave_like 'a list-only command'
end
