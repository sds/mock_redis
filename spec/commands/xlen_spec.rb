require 'spec_helper'

describe '#xlen(key)' do
  before { @key = 'mock-redis-test:xlen' }

  it 'returns the number of items in the stream' do
    expect(@redises.xlen(@key)).to eq 0
    @redises.xadd(@key, '*', 'key', 'value')
    expect(@redises.xlen(@key)).to eq 1
    3.times { @redises.xadd(@key, '*', 'key', 'value') }
    expect(@redises.xlen(@key)).to eq 4
  end

  it 'raises wrong number of arguments error with missing key' do
    expect { @redises.xlen }
      .to raise_error(
        Redis::CommandError,
        "ERR wrong number of arguments for 'xlen' command"
      )
  end

  it 'raises wrong number of arguments error with extra arguments' do
    expect { @redises.xlen(@key, 'xyz') }
      .to raise_error(
        Redis::CommandError,
        "ERR wrong number of arguments for 'xlen' command"
      )
  end
end
