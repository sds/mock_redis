require 'spec_helper'

describe '#xrange(key, start, end)' do
  before { @key = 'mock-redis-test:xrange' }

  it 'finds an empty range' do
    expect(@redises.xrange(@key, '-', '+')).to eq []
  end

  it 'finds a single entry with a full range' do
    @redises.xadd(@key, '1234567891234-0', 'key', 'value')
    expect(@redises.xrange(@key, '-', '+'))
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
      expect(@redises.xrange(@key, '-', '+')).to eq(
        [
          ['1234567891234-0', %w[key1 value1]],
          ['1234567891245-0', %w[key2 value2]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891278-1', %w[key5 value5]],
          ['1234567891299-0', %w[key6 value6]]
        ]
      )
    end

    it 'returns entries with a lower limit' do
      expect(@redises.xrange(@key, '1234567891239-0', '+')).to eq(
        [
          ['1234567891245-0', %w[key2 value2]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891278-1', %w[key5 value5]],
          ['1234567891299-0', %w[key6 value6]]
        ]
      )
    end

    it 'returns entries with an upper limit' do
      expect(@redises.xrange(@key, '-', '1234567891285-0')).to eq(
        [
          ['1234567891234-0', %w[key1 value1]],
          ['1234567891245-0', %w[key2 value2]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891278-1', %w[key5 value5]]
        ]
      )
    end

    it 'returns entries with both a lower and an upper limit' do
      expect(@redises.xrange(@key, '1234567891239-0', '1234567891285-0')).to eq(
        [
          ['1234567891245-0', %w[key2 value2]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891278-1', %w[key5 value5]]
        ]
      )
    end

    it 'finds the list with sequence numbers' do
      expect(@redises.xrange(@key, '1234567891245-1', '1234567891278-0')).to eq(
        [
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891278-0', %w[key4 value4]]
        ]
      )
    end

    it 'finds the list with lower bound without sequence numbers' do
      expect(@redises.xrange(@key, '1234567891245', '+')).to eq(
        [
          ['1234567891245-0', %w[key2 value2]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891278-1', %w[key5 value5]],
          ['1234567891299-0', %w[key6 value6]]
        ]
      )
    end

    it 'finds the list with upper bound without sequence numbers' do
      expect(@redises.xrange(@key, '-', '1234567891278')).to eq(
        [
          ['1234567891234-0', %w[key1 value1]],
          ['1234567891245-0', %w[key2 value2]],
          ['1234567891245-1', %w[key3 value3]],
          ['1234567891278-0', %w[key4 value4]],
          ['1234567891278-1', %w[key5 value5]]
        ]
      )
    end
  end
end
