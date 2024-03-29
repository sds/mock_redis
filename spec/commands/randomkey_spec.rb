require 'spec_helper'

RSpec.describe '#randomkey [mock only]' do
  before { @mock = @redises.mock }

  it 'finds a random key' do
    @keys = ['mock-redis-test:1', 'mock-redis-test:2', 'mock-redis-test:3']

    @keys.each do |k|
      @mock.set(k, 1)
    end

    expect(@keys).to include(@mock.randomkey)
  end

  it 'returns nil when there are no keys' do
    @mock.keys('*').each { |k| @mock.del(k) }
    expect(@mock.randomkey).to be_nil
  end
end
