require 'spec_helper'

RSpec.describe '#zrange(key, start, stop [, :with_scores => true])' do
  before do
    @key = 'mock-redis-test:zrange'
    @redises.zadd(@key, 3, 'Jefferson')
    @redises.zadd(@key, 1, 'Washington')
    @redises.zadd(@key, 2, 'Adams')
    @redises.zadd(@key, 4, 'Madison')
  end

  context 'when the zset is empty' do
    before do
      @redises.del(@key)
    end

    it 'should return an empty array' do
      expect(@redises.exists?(@key)).to eq(false)
      expect(@redises.zrange(@key, 0, 4)).to eq([])
    end
  end

  it 'returns the elements when the range is given as strings' do
    expect(@redises.zrange(@key, '0', '1')).to eq(%w[Washington Adams])
  end

  it 'returns the elements in order by score' do
    expect(@redises.zrange(@key, 0, 1)).to eq(%w[Washington Adams])
  end

  context 'when a subset of elements have the same score' do
    before do
      @redises.zadd(@key, 1, 'Martha')
    end

    it 'returns the elements in ascending lexicographical order' do
      expect(@redises.zrange(@key, 0, 1)).to eq(%w[Martha Washington])
    end
  end

  it 'returns the elements in order by score (negative indices)' do
    expect(@redises.zrange(@key, -2, -1)).to eq(%w[Jefferson Madison])
  end

  it 'returns empty list when start is too large' do
    expect(@redises.zrange(@key, 5, -1)).to eq([])
  end

  it 'returns entire list when start is out of bounds with negative end in bounds' do
    expect(@redises.zrange(@key, -5, -1)).to eq(%w[Washington Adams Jefferson Madison])
  end

  it 'returns correct subset when start is out of bounds with positive end in bounds' do
    expect(@redises.zrange(@key, -5, 1)).to eq(%w[Washington Adams])
  end

  it 'returns empty list when start is in bounds with negative end out of bounds' do
    expect(@redises.zrange(@key, 1, -5)).to eq([])
  end

  it 'returns empty list when start is 0 with negative end out of bounds' do
    expect(@redises.zrange(@key, 0, -5)).to eq([])
  end

  it 'returns correct subset when start is in bounds with negative end in bounds' do
    expect(@redises.zrange(@key, 1, -1)).to eq(%w[Adams Jefferson Madison])
  end

  it 'returns the scores when :with_scores is specified' do
    expect(@redises.zrange(@key, 0, 1, :with_scores => true)).
      to eq([['Washington', 1.0], ['Adams', 2.0]])
  end

  it 'returns the scores when :withscores is specified' do
    expect(@redises.zrange(@key, 0, 1, :withscores => true)).
      to eq([['Washington', 1.0], ['Adams', 2.0]])
  end

  context 'with byscore option', redis: '6.2' do
    it 'returns elements within score range' do
      expect(@redises.zrange(@key, 1, 2, byscore: true)).to eq(%w[Washington Adams])
    end

    it 'returns elements with scores when :with_scores is specified' do
      expect(@redises.zrange(@key, 1, 3, byscore: true, with_scores: true)).
        to eq([['Washington', 1.0], ['Adams', 2.0], ['Jefferson', 3.0]])
    end

    it 'returns empty array when no elements in range' do
      expect(@redises.zrange(@key, 10, 20, byscore: true)).to eq([])
    end

    it 'supports limit option' do
      expect(@redises.zrange(@key, 1, 4, byscore: true, limit: [0, 2])).
        to eq(%w[Washington Adams])
    end
  end

  context 'with rev option' do
    it 'returns elements in reverse order' do
      expect(@redises.zrange(@key, 0, 1, rev: true)).to eq(%w[Madison Jefferson])
    end

    it 'returns elements in reverse order with byscore', redis: '6.2' do
      expect(@redises.zrange(@key, 1, 3, byscore: true, rev: true)).
        to eq(%w[Jefferson Adams Washington])
    end
  end

  it_should_behave_like 'a zset-only command'
end
