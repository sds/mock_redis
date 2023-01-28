require 'spec_helper'

RSpec.describe '#rpoplpush(source, destination)' do
  before do
    @list1 = 'mock-redis-test:rpoplpush-list1'
    @list2 = 'mock-redis-test:rpoplpush-list2'

    @redises.lpush(@list1, 'b')
    @redises.lpush(@list1, 'a')

    @redises.lpush(@list2, 'y')
    @redises.lpush(@list2, 'x')
  end

  it 'returns the value moved' do
    expect(@redises.rpoplpush(@list1, @list2)).to eq('b')
  end

  it "returns false and doesn't append if source empty" do
    expect(@redises.rpoplpush('empty', @list1)).to be_nil
    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[a b])
  end

  it 'takes the last element of destination and prepends it to source' do
    @redises.rpoplpush(@list1, @list2)

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[a])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[b x y])
  end

  it 'rotates a list when source and destination are the same' do
    @redises.rpoplpush(@list1, @list1)
    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[b a])
  end

  it 'removes empty lists' do
    @redises.llen(@list1).times { @redises.rpoplpush(@list1, @list2) }
    expect(@redises.get(@list1)).to be_nil
  end

  it 'raises an error for non-list source value' do
    @redises.set(@list1, 'string value')

    expect do
      @redises.rpoplpush(@list1, @list2)
    end.to raise_error(Redis::CommandError)
  end

  it_should_behave_like 'a list-only command'
end
