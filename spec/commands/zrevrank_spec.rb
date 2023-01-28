require 'spec_helper'

RSpec.describe '#zrevrank(key, member)' do
  before do
    @key = 'mock-redis-test:zrevrank'

    @redises.zadd(@key, 1, 'one')
    @redises.zadd(@key, 2, 'two')
    @redises.zadd(@key, 3, 'three')
  end

  it "returns nil if member wasn't present in the set" do
    expect(@redises.zrevrank(@key, 'foo')).to be_nil
  end

  it 'returns the index of the member in the set (ordered by -score)' do
    expect(@redises.zrevrank(@key, 'one')).to eq(2)
    expect(@redises.zrevrank(@key, 'two')).to eq(1)
    expect(@redises.zrevrank(@key, 'three')).to eq(0)
  end

  it 'handles integer members correctly' do
    member = 11
    @redises.zadd(@key, 4, member)
    expect(@redises.zrevrank(@key, member)).to eq(0)
  end

  it_should_behave_like 'a zset-only command'
end
