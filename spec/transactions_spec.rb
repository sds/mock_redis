require 'spec_helper'

RSpec.describe 'transactions (multi/exec/discard)' do
  before(:each) do
    @redises.discard rescue nil
  end

  context '#multi' do
    it 'raises error' do
      expect { @redises.multi }.to raise_error(LocalJumpError, 'no block given (yield)')
    end

    it 'does not permit nesting' do
      expect do
        @redises.multi do |r1|
          r1.multi do |r2|
            r2.set('foo', 'bar')
          end
        end
      end.to raise_error(Redis::BaseError, "Can't nest multi transaction")
    end

    it 'cleans state of transaction wrapper if exception occurs during transaction' do
      expect do
        @redises.mock.multi do |_r|
          raise "i'm a command that fails"
        end
      end.to raise_error(RuntimeError)

      # before the fix this used to raised a #<RuntimeError: ERR MULTI calls can not be nested>
      expect do
        @redises.mock.multi do |r|
          # do stuff that succeed
          r.set(nil, 'string')
        end
      end.not_to raise_error
    end
  end

  context '#blocks' do
    it 'implicitly runs exec when finished' do
      @redises.set('counter', 5)
      @redises.multi do |r|
        r.set('test', 1)
        r.incr('counter')
      end
      expect(@redises.get('counter')).to eq '6'
      expect(@redises.get('test')).to eq '1'
    end

    it 'permits nesting via blocks' do
      # Have to use only the mock here. redis-rb has a bug in it where
      # nested #multi calls raise NoMethodError because it gets a nil
      # where it's not expecting one.
      @redises.mock.multi do |r|
        expect do
          r.multi {}
        end.to raise_error(Redis::BaseError, "Can't nest multi transaction")
      end
    end

    it 'allows pipelined calls within multi blocks' do
      @redises.set('counter', 5)
      @redises.multi do |r|
        r.pipelined do |pr|
          pr.set('test', 1)
          pr.incr('counter')
        end
      end
      expect(@redises.get('counter')).to eq '6'
      expect(@redises.get('test')).to eq '1'
    end

    it 'allows blocks within multi blocks' do
      @redises.set('foo', 'bar')
      @redises.set('fuu', 'baz')

      result = nil

      @redises.multi do |r|
        result = r.mget('foo', 'fuu') { |reply| reply.map(&:upcase) }
        r.del('foo', 'fuu')
      end

      expect(result.value).to eq %w[BAR BAZ]
      expect(@redises.get('foo')).to eq nil
      expect(@redises.get('fuu')).to eq nil
    end
  end

  context '#discard' do
    it 'runs automatically inside multi block if there is error' do
      begin
        @redises.multi do |r|
          r.set('foo', 'bar')
          raise StandardError
        end
      rescue StandardError
        # do nothing
      end

      expect(@redises.get('foo')).to eq nil
    end

    it "can't be run outside of #multi/#exec" do
      expect do
        @redises.discard
      end.to raise_error(Redis::CommandError)
    end
  end

  context '#exec' do
    it 'raises an error outside of #multi' do
      expect { @redises.exec }.to raise_error(Redis::CommandError)
    end
  end

  context 'saving up commands for later' do
    before(:each) do
      @string = 'mock-redis-test:string'
      @list = 'mock-redis-test:list'
    end

    it 'makes commands respond with MockRedis::Future' do
      result = []

      @redises.multi do |r|
        result << r.set(@string, 'string')
        result << r.lpush(@list, 'list')
      end

      expect(result[0].is_a?(Redis::Future)).to eq true
      expect(result[1].is_a?(Redis::Future)).to eq true
      expect(result[2]).to be_a(MockRedis::Future)
      expect(result[3]).to be_a(MockRedis::Future)

      expect(result[2].command).to eq [:set, @string, 'string']
      expect(result[3].command).to eq [:lpush, @list, 'list']
    end

    it "gives you the commands' responses when you call #exec" do
      result = @redises.multi do |r|
        r.set(@string, 'string')
        r.lpush(@list, 'list')
        r.lpush(@list, 'list')
      end

      expect(result).to eq ['OK', 1, 2]
    end

    it 'raises exceptions if one command fails' do
      expect do
        @redises.multi do |r|
          r.set(@string, 'string')
          r.lpush(@string, 'oops!')
          r.lpush(@list, 'list')
        end
      end.to raise_error(Redis::WrongTypeError)
    end
  end

  context 'saving commands with multi block' do
    before(:each) do
      @string = 'mock-redis-test:string'
      @list = 'mock-redis-test:list'
    end

    it 'commands return response after exec is called' do
      set_response = nil
      lpush_response = nil
      second_lpush_response = nil

      @redises.multi do |mult|
        set_response = mult.set(@string, 'string')
        lpush_response = mult.lpush(@list, 'list')
        second_lpush_response = mult.lpush(@list, 'list')
      end

      expect(set_response.value).to eq 'OK'
      expect(lpush_response.value).to eq 1
      expect(second_lpush_response.value).to eq 2
    end
  end
end
