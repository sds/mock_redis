require 'spec_helper'

RSpec.describe '#zrank(key, member)' do
  before do
    @key = 'mock-redis-test:zrank'

    @redises.zadd(@key, 1, 'one')
    @redises.zadd(@key, 2, 'two')
    @redises.zadd(@key, 3, 'three')
  end

  it "returns nil if member wasn't present in the set" do
    expect(@redises.zrank(@key, 'foo')).to be_nil
  end

  it 'returns the index of the member in the set' do
    expect(@redises.zrank(@key, 'one')).to eq(0)
    expect(@redises.zrank(@key, 'two')).to eq(1)
    expect(@redises.zrank(@key, 'three')).to eq(2)
  end

  it 'handles integer members correctly' do
    member = 11
    @redises.zadd(@key, 4, member)
    expect(@redises.zrank(@key, member)).to eq(3)
  end

  it_should_behave_like 'a zset-only command'
end
