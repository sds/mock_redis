require 'spec_helper'

RSpec.describe '#bitfield(*args)' do
  before :each do
    @key = 'mock-redis-test:bitfield'
    @redises.set(@key, '')

    @redises.bitfield(@key, :set, 'i8', 0, 78)
    @redises.bitfield(@key, :set, 'i8', 8, 104)
    @redises.bitfield(@key, :set, 'i8', 16, -59)
    @redises.bitfield(@key, :set, 'u8', 24, 78)
    @redises.bitfield(@key, :set, 'u8', 32, 84)
  end

  context 'with a :get command' do
    it 'gets a signed 8 bit value' do
      expect(@redises.bitfield(@key, :get, 'i8', 0)).to eq([78])
      expect(@redises.bitfield(@key, :get, 'i8', 8)).to eq([104])
      expect(@redises.bitfield(@key, :get, 'i8', 16)).to eq([-59])
    end

    it 'gets multiple values with multiple command args' do
      expect(@redises.bitfield(@key, :get, 'i8', 0,
                              :get, 'i8', 8,
                              :get, 'i8', 16)).to eq([78, 104, -59])
    end

    it 'gets multiple values using positional offsets' do
      expect(@redises.bitfield(@key, :get, 'i8', '#0',
                              :get, 'i8', '#1',
                              :get, 'i8', '#2')).to eq([78, 104, -59])
    end

    it 'shows an error with an invalid type' do
      expect do
        @redises.bitfield(@key, :get, 'u64', 0)
      end.to raise_error(Redis::CommandError)
      expect do
        @redises.bitfield(@key, :get, 'i128', 0)
      end.to raise_error(Redis::CommandError)
    end

    it 'does not throw an error with i64 type' do
      expect do
        @redises.bitfield(@key, :get, 'i64', 0)
      end.to_not raise_error
    end
  end

  context 'with a :set command' do
    it 'sets the bit values for an 8 bit signed integer' do
      expect(@redises.bitfield(@key, :set, 'i8', 0, 63)).to eq([78])
      expect(@redises.bitfield(@key, :set, 'i8', 8, -1)).to eq([104])
      expect(@redises.bitfield(@key, :set, 'i8', 16, 123)).to eq([-59])

      expect(@redises.bitfield(@key, :get, 'i8', 0,
                              :get, 'i8', 8,
                              :get, 'i8', 16)).to eq([63, -1, 123])
    end

    it 'sets multiple values with multiple command args' do
      expect(@redises.bitfield(@key, :set, 'i8', 0, 63,
                              :set, 'i8', 8, -1,
                              :set, 'i8', 16, 123)).to eq([78, 104, -59])

      expect(@redises.bitfield(@key, :get, 'i8', 0,
                              :get, 'i8', 8,
                              :get, 'i8', 16)).to eq([63, -1, 123])
    end
  end

  context 'with an :incrby command' do
    it 'returns the incremented by value for an 8 bit signed integer' do
      expect(@redises.bitfield(@key, :incrby, 'i8', 0, 1)).to eq([79])
      expect(@redises.bitfield(@key, :incrby, 'i8', 8, -1)).to eq([103])
      expect(@redises.bitfield(@key, :incrby, 'i8', 16, 5)).to eq([-54])
    end

    context 'with an overflow of wrap (default)' do
      context 'for a signed integer' do
        it 'wraps the overflow to the minimum and increments from there' do
          expect(@redises.bitfield(@key, :get, 'i8', 24)).to eq([78])
          expect(@redises.bitfield(@key, :overflow, :wrap,
                                  :incrby, 'i8', 0, 200)).to eq([22])
        end

        it 'wraps the underflow to the maximum value and decrements from there' do
          expect(@redises.bitfield(@key, :overflow, :wrap,
                                  :incrby, 'i8', 16, -200)).to eq([-3])
        end
      end

      context 'for an unsigned integer' do
        it 'wraps the overflow back to zero and increments from there' do
          expect(@redises.bitfield(@key, :get, 'u8', 24)).to eq([78])
          expect(@redises.bitfield(@key, :overflow, :wrap,
                                  :incrby, 'u8', 24, 233)).to eq([55])
        end

        it 'wraps the underflow to the maximum value and decrements from there' do
          expect(@redises.bitfield(@key, :get, 'u8', 32)).to eq([84])
          expect(@redises.bitfield(@key, :overflow, :wrap,
                                  :incrby, 'u8', 32, -233)).to eq([107])
        end
      end
    end

    context 'with an overflow of sat' do
      it 'sets the overflowed value to the maximum' do
        expect(@redises.bitfield(@key, :overflow, :sat,
                                :incrby, 'i8', 0, 256)).to eq([127])
      end

      it 'sets the underflowed value to the minimum' do
        expect(@redises.bitfield(@key, :overflow, :sat,
                                :incrby, 'i8', 16, -256)).to eq([-128])
      end
    end

    context 'with an overflow of fail' do
      it 'raises a redis error on an out of range value' do
        expect(@redises.bitfield(@key, :overflow, :fail,
                                :incrby, 'i8', 0, 256)).to eq([nil])

        expect(@redises.bitfield(@key, :overflow, :fail,
                                :incrby, 'i8', 16, -256)).to eq([nil])
      end

      it 'retains the original value after a failed increment' do
        expect(@redises.bitfield(@key, :get, 'i8', 0)).to eq([78])
        expect(@redises.bitfield(@key, :overflow, :fail,
                                :incrby, 'i8', 0, 256)).to eq([nil])
        expect(@redises.bitfield(@key, :get, 'i8', 0)).to eq([78])
      end
    end

    context 'with multiple overflow commands in one transaction' do
      it 'handles the overflow values correctly' do
        expect(@redises.bitfield(@key, :overflow, :sat,
                                :incrby, 'i8', 0, 256,
                                :incrby, 'i8', 8, -256,
                                :overflow, :wrap,
                                :incrby, 'i8', 0, 200,
                                :incrby, 'i8', 16, -200,
                                :overflow, :fail,
                                :incrby, 'i8', 0, 256,
                                :incrby, 'i8', 16, -256)).to eq([127, -128, 71, -3, nil, nil])
      end
    end

    context 'with an unsupported overflow value' do
      it 'raises an error' do
        expect do
          @redises.bitfield(@key, :overflow, :foo,
                                  :incrby, 'i8', 0, 256)
        end.to raise_error(Redis::CommandError)
      end
    end
  end

  context 'with a mixed set of commands' do
    it 'returns the correct outputs' do
      expect(@redises.bitfield(@key, :set, 'i8', 0, 38,
                              :set, 'i8', 8, -99,
                              :incrby, 'i8', 16, 1,
                              :get, 'i8', 0)).to eq([78, 104, -58, 38])
    end
  end
end
