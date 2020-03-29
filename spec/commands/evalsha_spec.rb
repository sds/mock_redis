require 'spec_helper'

describe '#evalsha(*)' do
  let(:script) { 'return nil' }
  let(:script_digest) { Digest::SHA1.hexdigest(script) }

  it 'returns nothing' do
    @redises.evalsha(script_digest).should be_nil
  end

  context 'with "evalsha" config' do
    it 'executes the proc' do
      block = proc { |redis, args| redis.set(args[0], args[1]) }
      mock = MockRedis.new(evalsha: block)

      mock.evalsha('foo', 'bar')
      mock.get('foo').should == 'bar'
    end
  end
end
