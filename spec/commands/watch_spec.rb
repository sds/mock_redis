require 'spec_helper'

describe '#watch(key)' do
  it "responds with nil" do
    @redises.watch('mock-redis-test').should be_nil
  end
end
