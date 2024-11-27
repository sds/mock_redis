require 'spec_helper'

RSpec.describe '#incrbyfloat(key, increment)' do
  before { @key = 'mock-redis-test:65374' }

  it 'returns the value after the increment' do
    @redises.set(@key, 2.0)
    expect(@redises.incrbyfloat(@key, 2.1)).to be_within(0.0001).of(4.1)
  end

  it 'treats a missing key like 0' do
    expect(@redises.incrbyfloat(@key, 1.2)).to be_within(0.0001).of(1.2)
  end

  it 'increments negative numbers' do
    @redises.set(@key, -10.4)
    expect(@redises.incrbyfloat(@key, 2.3)).to be_within(0.0001).of(-8.1)
  end

  it 'works multiple times' do
    expect(@redises.incrbyfloat(@key, 2.1)).to be_within(0.0001).of(2.1)
    expect(@redises.incrbyfloat(@key, 2.2)).to be_within(0.0001).of(4.3)
    expect(@redises.incrbyfloat(@key, 2.3)).to be_within(0.0001).of(6.6)
  end

  it 'accepts an float-ish string' do
    expect(@redises.incrbyfloat(@key, '2.2')).to be_within(0.0001).of(2.2)
  end

  it 'raises an error if the value does not look like an float' do
    @redises.set(@key, 'one.two')
    expect do
      @redises.incrbyfloat(@key, 1)
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if the delta does not look like an float' do
    expect do
      @redises.incrbyfloat(@key, 'foobar.baz')
    end.to raise_error(ArgumentError)
  end

  it_should_behave_like 'a string-only command'
end
