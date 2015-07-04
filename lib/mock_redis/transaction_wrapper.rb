require 'mock_redis/undef_redis_methods'

class MockRedis
  class TransactionWrapper
    include UndefRedisMethods

    def respond_to?(method, include_private = false)
      super || @db.respond_to?(method)
    end

    def initialize(db)
      @db = db
      @transaction_futures = []
      @in_multi = false
      @multi_block_given = false
    end

    def method_missing(method, *args, &block)
      if @in_multi
        future = MockRedis::Future.new([method, *args])
        @transaction_futures << future

        if @multi_block_given
          future
        else
          'QUEUED'
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
    end

    def discard
      unless @in_multi
        raise Redis::CommandError, 'ERR DISCARD without MULTI'
      end
      @in_multi = false
      @multi_block_given = false
      @transaction_futures = []
      'OK'
    end

    def exec
      unless @in_multi
        raise Redis::CommandError, 'ERR EXEC without MULTI'
      end
      @in_multi = false
      @multi_block_given = false

      responses = @transaction_futures.map do |future|
        begin
          result = send(*future.command)
          future.store_result(result)
          result
        rescue => e
          e
        end
      end

      @transaction_futures = []
      responses
    end

    def multi
      if @in_multi
        raise Redis::CommandError, 'ERR MULTI calls can not be nested'
      end
      @in_multi = true
      if block_given?
        @multi_block_given = true
        begin
          yield(self)
          exec
        rescue StandardError => e
          discard
          raise e
        end
      else
        'OK'
      end
    end

    def unwatch
      'OK'
    end

    def watch(_)
      if block_given?
        yield self
      else
        'OK'
      end
    end
  end
end
