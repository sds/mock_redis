require 'spec_helper'

describe '#xadd(key, id, [field, value, ...])' do
  before :all do
    sleep 1 - (Time.now.to_f % 1)
    @key = 'mock-redis-test:xadd'
  end

  before :each do
    @redises._gsub(/\d{3}-\d/, '...-.')
  end

  it 'returns an id based on the timestamp' do
    t = Time.now.to_i
    expect(@redises.xadd(@key, '*', 'key', 'value')).to match(/#{t}\d{3}-0/)
  end

  it 'adds data with symbols' do
    @redises.xadd(@key, '*', :symbol_key, :symbol_value)
    expect(@redises.xrange(@key, '-', '+').last[1])
      .to eq(%w[symbol_key symbol_value])
  end

  it 'increments the sequence number with the same timestamp' do
    Timecop.freeze do
      @redises.xadd(@key, '*', 'key', 'value')
      expect(@redises.xadd(@key, '*', 'key', 'value')).to match(/\d+-1/)
    end
  end

  it 'sets the id if it is given' do
    expect(@redises.xadd(@key, '1234567891234-2', 'key', 'value'))
      .to eq '1234567891234-2'
  end

  it 'accepts is as an integer' do
    expect(@redises.xadd(@key, 1_234_567_891_234, 'key', 'value'))
      .to eq '1234567891234-0'
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
    expect(@redises.xadd(@key, '*', 'key', 'value')).to match(/#{t}-1/)
  end

  it 'appends a sequence number if it is missing' do
    expect(@redises.xadd(@key, '1234567891234', 'key', 'value'))
      .to eq '1234567891234-0'
  end

  it 'raises wrong number of arguments error with missing values' do
    expect { @redises.xadd(@key, '*') }
      .to raise_error(
        Redis::CommandError,
        "ERR wrong number of arguments for 'xadd' command"
      )
  end

  it 'raises wrong number of arguments error with odd number of values' do
    expect { @redises.xadd(@key, '*', 'key', 'value', 'key') }
      .to raise_error(
        Redis::CommandError,
        'ERR wrong number of arguments for XADD'
      )
  end

  it 'raises an invalid stream id error' do
    expect { @redises.xadd(@key, 'X', 'key', 'value') }
      .to raise_error(
        Redis::CommandError,
        'ERR Invalid stream ID specified as stream command argument'
      )
  end
end
