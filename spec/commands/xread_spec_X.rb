require 'spec_helper'

describe '#xread' do
  before { @key = 'mock-redis-test:xread' }

  context 'six items on the list' do
    before :each do
      @redises.xadd(@key, '1234567891234-0', 'key1', 'value1')
      @redises.xadd(@key, '1234567891245-0', 'key2', 'value2')
      @redises.xadd(@key, '1234567891245-1', 'key3', 'value3')
      @redises.xadd(@key, '1234567891278-0', 'key4', 'value4')
      @redises.xadd(@key, '1234567891278-1', 'key5', 'value5')
      @redises.xadd(@key, '1234567891299-0', 'key6', 'value6')
    end

    it 'returns all items in a stream' do
      expect(@redises.xread('streams', @key, 0)).to eq(
        [
          [
            @key,
            [
              ['1234567891234-0', %w[key1 value1]],
              ['1234567891245-0', %w[key2 value2]],
              ['1234567891245-1', %w[key3 value3]],
              ['1234567891278-0', %w[key4 value4]],
              ['1234567891278-1', %w[key5 value5]],
              ['1234567891299-0', %w[key6 value6]]
            ]
          ]
        ]
      )
    end
  end
end
