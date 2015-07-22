require 'spec_helper'

describe MockRedis::Future do
  let(:command) { [:get, 'foo'] }
  let(:result)  { 'bar' }
  before        { @future = MockRedis::Future.new(command) }

  it 'remembers the command' do
    @future.command.should eq(command)
  end

  it 'raises an error if the value is requested before the result is set' do
    expect { @future.value }.to raise_error(MockRedis::FutureNotReady)
  end

  it 'returns the value after the result has been set' do
    @future.store_result(result)
    @future.value.should eq(result)
  end
end
