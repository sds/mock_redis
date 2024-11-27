require 'mock_redis/undef_redis_methods'
require 'mock_redis/error'

class MockRedis
  class TransactionWrapper
    include UndefRedisMethods

    def respond_to?(method, include_private = false)
      super || @db.respond_to?(method)
    end

    def initialize(db)
      @db = db
      @transaction_futures = []
      @multi_stack = []
    end

    ruby2_keywords def method_missing(method, *args, &block)
      if in_multi?
        MockRedis::Future.new([method, *args], block).tap do |future|
          @transaction_futures << future
        end
      else
        @db.expire_keys
        @db.send(method, *args, &block)
      end
    end

    def initialize_copy(source)
      super
      @db = @db.clone
      @transaction_futures = @transaction_futures.clone
      @multi_stack = @multi_stack.clone
    end

    def discard
      unless in_multi?
        raise Error.command_error('ERR DISCARD without MULTI', self)
      end
      pop_multi

      @transaction_futures = []
      'OK'
    end

    def exec
      unless in_multi?
        raise Error.command_error('ERR EXEC without MULTI', self)
      end

      pop_multi
      return if in_multi?

      responses = @transaction_futures.map do |future|
        result = send(*future.command)
        future.store_result(result)
        future.value
      end

      responses
    ensure
      # At this point, multi is done, so we can't call discard anymore.
      # Therefore, we need to clear the transaction futures manually.
      @transaction_futures = []
    end

    def in_multi?
      @multi_stack.any?
    end

    def push_multi
      @multi_stack.push(@multi_stack.size + 1)
    end

    def pop_multi
      @multi_stack.pop
    end

    def multi
      raise Redis::BaseError, "Can't nest multi transaction" if in_multi?

      push_multi

      begin
        yield(self)
        exec
      rescue StandardError => e
        discard if in_multi?
        raise e
      end
    end

    def pipelined
      yield(self) if block_given?
    end

    def unwatch
      'OK'
    end

    def watch(*_)
      if block_given?
        yield self
      else
        'OK'
      end
    end
  end
end
