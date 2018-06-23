require 'spec_helper'

describe '#xrevrange(key, start, end)' do
  before { @key = 'mock-redis-test:xrevrange' }

  it 'finds an empty range' do
    expect(@redises.xrevrange(@key, '-', '+')).to eq []
  end

  it 'finds a single entry with a full range' do
    @redises.xadd(@key, '1234567891234-0', 'key', 'value')
    expect(@redises.xrevrange(@key, '+', '-'))
      .to eq [['1234567891234-0', %w[key value]]]
  end

  context 'six items on the list' do
    before :each do
      @redises.xadd(@key, '1234567891234-0', 'key1', 'value1')
      @redises.xadd(@key, '1234567891245-0', 'key2', 'value2')
      @redises.xadd(@key, '1234567891245-1', 'key3', 'value3')
      @redises.xadd(@key, '1234567891278-0', 'key4', 'value4')
      @redises.xadd(@key, '1234567891278-1', 'key5', 'value5')
      @redises.xadd(@key, '1234567891299-0', 'key6', 'value6')
    end

    it 'returns entries in sequential order' do
      expect(@redises.xrevrange(@key, '+', '-')).to eq(
        [
          ['1234567891299-0', %w[key6 value6]],
          ['1234567891278-1', %w[key5 value5]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891245-0', %w[key2 value2]],
          ['1234567891234-0', %w[key1 value1]],
        ]
      )
    end

    it 'returns entries with a lower limit' do
      expect(@redises.xrevrange(@key, '+', '1234567891239-0')).to eq(
        [
          ['1234567891299-0', %w[key6 value6]],
          ['1234567891278-1', %w[key5 value5]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891245-0', %w[key2 value2]],
        ]
      )
    end

    it 'returns entries with an upper limit' do
      require 'pry'
      expect(@redises.xrevrange(@key, '1234567891285-0', '-')).to eq(
        [
          ['1234567891278-1', %w[key5 value5]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891245-0', %w[key2 value2]],
          ['1234567891234-0', %w[key1 value1]],
        ]
      )
    end

    it 'returns entries with both a lower and an upper limit' do
      expect(@redises.xrevrange(@key, '1234567891285-0', '1234567891239-0')).to eq(
        [
          ['1234567891278-1', %w[key5 value5]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891245-0', %w[key2 value2]],
        ]
      )
    end

    it 'finds the list with sequence numbers' do
      expect(@redises.xrevrange(@key, '1234567891278-0', '1234567891245-1')).to eq(
        [
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891245-1', %w[key3 value3]],
        ]
      )
    end

    it 'finds the list with lower bound without sequence numbers' do
      expect(@redises.xrevrange(@key, '+', '1234567891245')).to eq(
        [
          ['1234567891299-0', %w[key6 value6]],
          ['1234567891278-1', %w[key5 value5]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891245-0', %w[key2 value2]],
        ]
      )
    end

    it 'finds the list with upper bound without sequence numbers' do
      expect(@redises.xrevrange(@key, '1234567891278', '-')).to eq(
        [
          ['1234567891278-1', %w[key5 value5]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891245-0', %w[key2 value2]],
          ['1234567891234-0', %w[key1 value1]],
        ]
      )
    end

    it 'returns a limited number of items' do
      expect(@redises.xrevrange(@key, '+', '-', 'COUNT', '2')).to eq(
        [
          ['1234567891299-0', %w[key6 value6]],
          ['1234567891278-1', %w[key5 value5]],
        ]
      )
      expect(@redises.xrevrange(@key, '+', '-', 'count', '2')).to eq(
        [
          ['1234567891299-0', %w[key6 value6]],
          ['1234567891278-1', %w[key5 value5]],
        ]
      )
    end
  end

  it 'raises wrong number of arguments error' do
    expect { @redises.xrevrange(@key, '+') }
      .to raise_error(
        Redis::CommandError,
        "ERR wrong number of arguments for 'xrevrange' command"
      )
  end

  it 'raises syntax error with missing count number' do
    expect { @redises.xrevrange(@key, '+', '-', 'count') }
      .to raise_error(
        Redis::CommandError,
        'ERR syntax error'
      )
  end

  it 'raises not an integer error with bad count argument' do
    expect { @redises.xrevrange(@key, '+', '-', 'count', 'X') }
      .to raise_error(
        Redis::CommandError,
        'ERR value is not an integer or out of range'
      )
  end

  it 'raises an invalid stream id error' do
    expect { @redises.xrevrange(@key, 'X', '-') }
      .to raise_error(
        Redis::CommandError,
        'ERR Invalid stream ID specified as stream command argument'
      )
  end
end
