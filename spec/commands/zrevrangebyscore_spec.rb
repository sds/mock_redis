require 'spec_helper'

RSpec.describe '#zrevrangebyscore(key, start, stop '\
               '[:with_scores => true] [:limit => [offset count]])' do
  before do
    @key = 'mock-redis-test:zrevrangebyscore'
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
      expect(@redises.zrevrangebyscore(@key, 0, 4)).to eq([])
    end
  end

  it 'returns the elements in order by score' do
    expect(@redises.zrevrangebyscore(@key, 4, 3)).to eq(%w[Madison Jefferson])
  end

  it 'returns the scores when :with_scores is specified' do
    expect(@redises.zrevrangebyscore(@key, 4, 3, :with_scores => true)).
      to eq([['Madison', 4.0], ['Jefferson', 3.0]])
  end

  it 'returns the scores when :withscores is specified' do
    expect(@redises.zrevrangebyscore(@key, 4, 3, :withscores => true)).
      to eq([['Madison', 4.0], ['Jefferson', 3.0]])
  end

  it 'treats +inf as positive infinity' do
    expect(@redises.zrevrangebyscore(@key, '+inf', 3)).
      to eq(%w[Madison Jefferson])
  end

  it 'honors the :limit => [offset count] argument' do
    expect(@redises.zrevrangebyscore(@key, 100, -100, :limit => [1, 2])).
      to eq(%w[Jefferson Adams])
  end

  it "raises an error if :limit isn't a 2-tuple" do
    expect do
      @redises.zrevrangebyscore(@key, 100, -100, :limit => [1, 2, 3])
    end.to raise_error(Redis::CommandError)

    expect do
      @redises.zrevrangebyscore(@key, 100, -100, :limit => '1, 2')
    end.to raise_error(RedisMultiplexer::MismatchedResponse)
  end

  it_should_behave_like 'a zset-only command'
end
