require 'spec_helper'

  p Rspec::Version::STRING

describe MockRedis::Future do

  let(:command) { [:get, 'foo'] }
  let(:result) { 'bar' }

  before(:each) do
    @future = MockRedis::Future.new(command)
  end

  it 'should remember the command' do
    @future.command.should eq(command)
  end

  it 'should raise an error if the value is requested before the result is set' do
    expect{@future.value}.to raise_error(RuntimeError)
  end

  it 'should return the value after the result has been set' do
    @future.set_result(result)

    @future.value.should eq(result)
  end

end
