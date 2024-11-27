require 'spec_helper'

RSpec.describe '#hincrbyfloat(key, field, increment)' do
  before do
    @key = 'mock-redis-test:hincrbyfloat'
    @field = 'count'
  end

  it 'returns the value after the increment' do
    @redises.hset(@key, @field, 2.0)
    expect(@redises.hincrbyfloat(@key, @field, 2.1)).to be_within(0.0001).of(4.1)
  end

  it 'treats a missing key like 0' do
    expect(@redises.hincrbyfloat(@key, @field, 1.2)).to be_within(0.0001).of(1.2)
  end

  it 'creates a hash if nothing is present' do
    @redises.hincrbyfloat(@key, @field, 1.0)
    expect(@redises.hget(@key, @field)).to eq('1')
  end

  it 'increments negative numbers' do
    @redises.hset(@key, @field, -10.4)
    expect(@redises.hincrbyfloat(@key, @field, 2.3)).to be_within(0.0001).of(-8.1)
  end

  it 'works multiple times' do
    expect(@redises.hincrbyfloat(@key, @field, 2.1)).to be_within(0.0001).of(2.1)
    expect(@redises.hincrbyfloat(@key, @field, 2.2)).to be_within(0.0001).of(4.3)
    expect(@redises.hincrbyfloat(@key, @field, 2.3)).to be_within(0.0001).of(6.6)
  end

  it 'accepts a float-ish string' do
    expect(@redises.hincrbyfloat(@key, @field, '2.2')).to be_within(0.0001).of(2.2)
  end

  it 'treats the field as a string' do
    field = 11
    @redises.hset(@key, field, 2)
    expect(@redises.hincrbyfloat(@key, field, 2)).to eq(4.0)
  end

  it 'raises an error if the value does not look like a float' do
    @redises.hset(@key, @field, 'one.two')
    expect do
      @redises.hincrbyfloat(@key, @field, 1)
    end.to raise_error(Redis::CommandError)
  end

  it 'raises an error if the delta does not look like a float' do
    expect do
      @redises.hincrbyfloat(@key, @field, 'foobar.baz')
    end.to raise_error(ArgumentError)
  end

  it_should_behave_like 'a hash-only command'
end
