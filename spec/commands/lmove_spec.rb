require 'spec_helper'

RSpec.describe '#lmove(source, destination, wherefrom, whereto)' do
  before do
    @list1 = 'mock-redis-test:lmove-list1'
    @list2 = 'mock-redis-test:lmove-list2'

    @redises.lpush(@list1, 'b')
    @redises.lpush(@list1, 'a')

    @redises.lpush(@list2, 'y')
    @redises.lpush(@list2, 'x')
  end

  it 'returns the value moved' do
    expect(@redises.lmove(@list1, @list2, 'left', 'right')).to eq('a')
  end

  it "returns nil and doesn't append if source empty" do
    expect(@redises.lmove('empty', @list1, 'left', 'right')).to be_nil
    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[a b])
  end

  it 'takes the first element of source and prepends it to destination' do
    @redises.lmove(@list1, @list2, 'left', 'left')

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[b])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[a x y])
  end

  it 'takes the first element of source and appends it to destination' do
    @redises.lmove(@list1, @list2, 'left', 'right')

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[b])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[x y a])
  end

  it 'takes the last element of source and prepends it to destination' do
    @redises.lmove(@list1, @list2, 'right', 'left')

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[a])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[b x y])
  end

  it 'takes the last element of source and appends it to destination' do
    @redises.lmove(@list1, @list2, 'right', 'right')

    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[a])
    expect(@redises.lrange(@list2, 0, -1)).to eq(%w[x y b])
  end

  it 'rotates a list when source and destination are the same' do
    @redises.lmove(@list1, @list1, 'left', 'right')
    expect(@redises.lrange(@list1, 0, -1)).to eq(%w[b a])
  end

  it 'removes empty lists' do
    @redises.llen(@list1).times { @redises.lmove(@list1, @list2, 'left', 'right') }
    expect(@redises.get(@list1)).to be_nil
  end

  it 'raises an error for non-list source value' do
    @redises.set(@list1, 'string value')

    expect do
      @redises.lmove(@list1, @list2, 'left', 'right')
    end.to raise_error(Redis::CommandError)
  end

  it 'raises error if wherefrom is not left or right' do
    expect do
      @redises.lmove(@list1, @list2, 'oops', 'right')
    end.to raise_error(ArgumentError, "where_source must be 'LEFT' or 'RIGHT'")
  end

  it 'raises error if whereto is not left or right' do
    expect do
      @redises.lmove(@list1, @list2, 'left', 'oops')
    end.to raise_error(ArgumentError, "where_destination must be 'LEFT' or 'RIGHT'")
  end

  let(:default_error) { RedisMultiplexer::MismatchedResponse }
  it_should_behave_like 'a list-only command'
end
