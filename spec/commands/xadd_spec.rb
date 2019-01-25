require 'spec_helper'

describe '#xadd("mystream", { f1: "v1", f2: "v2" }, id: "0-0", maxlen: 1000, approximate: true)' do
  before :all do
    sleep 1 - (Time.now.to_f % 1)
    @key = 'mock-redis-test:xadd'
  end

  before :each do
    @redises._gsub(/\d{3}-\d/, '...-.')
  end

  it 'returns an id based on the timestamp' do
    t = Time.now.to_i
    expect(@redises.xadd(@key, key: 'value')).to match(/#{t}\d{3}-0/)
  end

  it 'adds data with symbols' do
    @redises.xadd(@key, symbol_key: :symbol_value)
    expect(@redises.xrange(@key, '-', '+').last[1])
      .to eq('symbol_key' => 'symbol_value')
  end

  it 'increments the sequence number with the same timestamp' do
    Timecop.freeze do
      @redises.xadd(@key, key: 'value')
      expect(@redises.xadd(@key, key: 'value')).to match(/\d+-1/)
    end
  end

  it 'sets the id if it is given' do
    expect(@redises.xadd(@key, { key: 'value' }, id: '1234567891234-2'))
      .to eq '1234567891234-2'
  end

  it 'accepts is as an integer' do
    expect(@redises.xadd(@key, { key: 'value' }, id: 1_234_567_891_234))
      .to eq '1234567891234-0'
  end

  it 'sets an id based on the timestamp if the given id is before the last' do
    @redises.xadd(@key, { key: 'value' }, id: '1234567891234-0')
    expect { @redises.xadd(@key, { key: 'value' }, id: '1234567891233-0') }
      .to raise_error(
        Redis::CommandError,
        'ERR The ID specified in XADD is equal or smaller than the target ' \
        'stream top item'
      )
  end

  it 'caters for the current time being before the last time' do
    t = (Time.now.to_f * 1000).to_i + 2000
    @redises.xadd(@key, { key: 'value' }, id: "#{t}-0")
    expect(@redises.xadd(@key, key: 'value')).to match(/#{t}-1/)
  end

  it 'appends a sequence number if it is missing' do
    expect(@redises.xadd(@key, { key: 'value' }, id: '1234567891234'))
      .to eq '1234567891234-0'
  end

  it 'raises an invalid stream id error' do
    expect { @redises.xadd(@key, { key: 'value' }, id: 'X') }
      .to raise_error(
        Redis::CommandError,
        'ERR Invalid stream ID specified as stream command argument'
      )
  end

  it 'caps the stream to 5 elements' do
    @redises.xadd(@key, { key1: 'value1' }, id: '1234567891234-0')
    @redises.xadd(@key, { key2: 'value2' }, id: '1234567891245-0')
    @redises.xadd(@key, { key3: 'value3' }, id: '1234567891245-1')
    @redises.xadd(@key, { key4: 'value4' }, id: '1234567891278-0')
    @redises.xadd(@key, { key5: 'value5' }, id: '1234567891278-1')
    @redises.xadd(@key, { key6: 'value6' }, id: '1234567891299-0')
    @redises.xadd(@key, { key7: 'value7' }, id: '1234567891300-0', maxlen: 5)
    expect(@redises.xrange(@key, '-', '+')).to eq(
      [
        ['1234567891245-1', { 'key3' => 'value3' }],
        ['1234567891278-0', { 'key4' => 'value4' }],
        ['1234567891278-1', { 'key5' => 'value5' }],
        ['1234567891299-0', { 'key6' => 'value6' }],
        ['1234567891300-0', { 'key7' => 'value7' }]
      ]
    )
  end
end

# Redis::CommandError: ERR The ID specified in XADD is equal or smaller than the target stream top item