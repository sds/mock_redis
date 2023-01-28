require 'spec_helper'

RSpec.describe '#hsetnx(key, field)' do
  before do
    @key = 'mock-redis-test:hsetnx'
  end

  it 'returns true if the field is absent' do
    expect(@redises.hsetnx(@key, 'field', 'val')).to eq(true)
  end

  it 'returns 0 if the field is present' do
    @redises.hset(@key, 'field', 'val')
    expect(@redises.hsetnx(@key, 'field', 'val')).to eq(false)
  end

  it 'leaves the field unchanged if the field is present' do
    @redises.hset(@key, 'field', 'old')
    @redises.hsetnx(@key, 'field', 'new')
    expect(@redises.hget(@key, 'field')).to eq('old')
  end

  it 'sets the field if the field is absent' do
    @redises.hsetnx(@key, 'field', 'new')
    expect(@redises.hget(@key, 'field')).to eq('new')
  end

  it 'creates a hash if there is no such field' do
    @redises.hsetnx(@key, 'field', 'val')
    expect(@redises.hget(@key, 'field')).to eq('val')
  end

  it 'stores values as strings' do
    @redises.hsetnx(@key, 'num', 1)
    expect(@redises.hget(@key, 'num')).to eq('1')
  end

  it 'stores fields as strings' do
    @redises.hsetnx(@key, 1, 'one')
    expect(@redises.hget(@key, '1')).to eq('one')
  end

  it_should_behave_like 'a hash-only command'
end
