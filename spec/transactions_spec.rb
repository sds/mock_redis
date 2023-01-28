require 'spec_helper'

RSpec.describe 'transactions (multi/exec/discard)' do
  before(:each) do
    @redises.discard rescue nil
  end

  context '#multi' do
    it "responds with 'OK'" do
      expect(@redises.multi).to eq('OK')
    end

    it 'does not permit nesting' do
      @redises.multi
      expect do
        @redises.multi
      end.to raise_error(Redis::CommandError, 'ERR MULTI calls can not be nested')
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
        end.not_to raise_error
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
    it "responds with 'OK' after #multi" do
      @redises.multi
      expect(@redises.discard).to eq 'OK'
    end

    it "can't be run outside of #multi/#exec" do
      expect do
        @redises.discard
      end.to raise_error(Redis::CommandError)
    end
  end

  context '#exec' do
    it 'raises an error outside of #multi' do
      lambda do
        expect(@redises.exec).to raise_error
      end
    end
  end

  context 'saving up commands for later' do
    before(:each) do
      @redises.multi
      @string = 'mock-redis-test:string'
      @list = 'mock-redis-test:list'
    end

    it "makes commands respond with 'QUEUED'" do
      expect(@redises.set(@string, 'string')).to eq 'QUEUED'
      expect(@redises.lpush(@list, 'list')).to eq 'QUEUED'
    end

    it "gives you the commands' responses when you call #exec" do
      @redises.set(@string, 'string')
      @redises.lpush(@list, 'list')
      @redises.lpush(@list, 'list')

      expect(@redises.exec).to eq ['OK', 1, 2]
    end

    it "does not raise exceptions, but rather puts them in #exec's response" do
      @redises.set(@string, 'string')
      @redises.lpush(@string, 'oops!')
      @redises.lpush(@list, 'list')

      responses = @redises.exec
      expect(responses[0]).to eq 'OK'
      expect(responses[1]).to be_a(Redis::CommandError)
      expect(responses[2]).to eq 1
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
