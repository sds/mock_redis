require 'spec_helper'

describe '#xadd(key, id, [field, value, ...])' do
  before { @key = 'mock-redis-test:xadd' }

  it 'returns an id based on the timestamp' do
    t = Time.now.to_i
    expect(@redises.xadd(@key, '*', 'key', 'value')).to match /#{t}\d{3}-0/
  end

  it 'sets the id if it is given' do
    expect(@redises.xadd(@key, '1234567891234-2', 'key', 'value'))
      .to eq '1234567891234-2'
  end

  it 'sets an id based on the timestamp if the given id is before the last' do
    @redises.xadd(@key, '1234567891234-0', 'key', 'value')
    expect { @redises.xadd(@key, '1234567891233-0', 'key', 'value') }
      .to raise_error(
        Redis::CommandError,
        'ERR The ID specified in XADD is equal or smaller than the target ' \
        'stream top item'
      )
  end

  it 'caters for the current time being before the last time' do
    t = DateTime.now.strftime('%Q').to_i + 2000
    @redises.xadd(@key, "#{t}-0", 'key', 'value')
    expect(@redises.xadd(@key, '*', 'key', 'value')).to match /#{t}-1/
  end

  it 'appends a sequence number if it is missing' do
    expect(@redises.xadd(@key, '1234567891234', 'key', 'value'))
      .to eq '1234567891234-0'
  end
end
