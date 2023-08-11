require 'spec_helper'

RSpec.describe '#zrangebyscore(key, start, stop '\
               '[:with_scores => true] [:limit => [offset count]])' do
  before do
    @key = 'mock-redis-test:zrangebyscore'
    @redises.zadd(@key, 1, 'Washington')
    @redises.zadd(@key, 2, 'Adams')
    @redises.zadd(@key, 3, 'Jefferson')
    @redises.zadd(@key, 4, 'Madison')
  end

  context 'when the zset is empty' do
    before do
      @redises.del(@key)
    end

    it 'should return an empty array' do
      expect(@redises.exists?(@key)).to eq(false)
      expect(@redises.zrangebyscore(@key, 0, 4)).to eq([])
    end
  end

  it 'returns the elements in order by score' do
    expect(@redises.zrangebyscore(@key, 1, 2)).to eq(%w[Washington Adams])
  end

  it 'returns the scores when :with_scores is specified' do
    expect(@redises.zrangebyscore(@key, 1, 2, :with_scores => true)).
      to eq([['Washington', 1.0], ['Adams', 2.0]])
  end

  it 'returns the scores when :withscores is specified' do
    expect(@redises.zrangebyscore(@key, 1, 2, :withscores => true)).
      to eq([['Washington', 1.0], ['Adams', 2.0]])
  end

  it 'honors the :limit => [offset count] argument' do
    expect(@redises.zrangebyscore(@key, -100, 100, :limit => [1, 2])).
      to eq(%w[Adams Jefferson])
  end

  it "raises an error if :limit isn't a 2-tuple" do
    expect do
      @redises.zrangebyscore(@key, -100, 100, :limit => [1, 2, 3])
    end.to raise_error(Redis::CommandError)

    expect do
      @redises.zrangebyscore(@key, -100, 100, :limit => '1, 2')
    end.to raise_error(RedisMultiplexer::MismatchedResponse)
  end

  it 'treats scores like floats, not strings' do
    @redises.zadd(@key, '10', 'Tyler')
    expect(@redises.zrangebyscore(@key, 1, 2)).to eq(%w[Washington Adams])
  end

  it 'treats -inf as negative infinity' do
    expect(@redises.zrangebyscore(@key, '-inf', 3)).to eq(
      %w[Washington Adams Jefferson]
    )
  end

  it 'treats +inf as positive infinity' do
    expect(@redises.zrangebyscore(@key, 3, '+inf')).to eq(%w[Jefferson Madison])
  end

  it 'treats +inf as positive infinity' do
    expect(@redises.zrangebyscore(@key, 3, '+inf')).to eq(%w[Jefferson Madison])
  end

  it 'honors exclusive ranges on the left' do
    expect(@redises.zrangebyscore(@key, '(3', 4)).to eq(['Madison'])
  end

  it 'honors exclusive ranges on the right' do
    expect(@redises.zrangebyscore(@key, '3', '(4')).to eq(['Jefferson'])
  end

  it 'honors exclusive ranges on the left and the right simultaneously' do
    expect(@redises.zrangebyscore(@key, '(1', '(4')).to eq(%w[Adams Jefferson])
  end

  it_should_behave_like 'a zset-only command'
end
