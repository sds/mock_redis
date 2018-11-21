require 'mock_redis/assertions'
require 'mock_redis/utility_methods'
require 'mock_redis/stream'

class MockRedis
  module StreamMethods
    include Assertions
    include UtilityMethods

    def xadd(key = nil, id = nil, *args)
      if args.count == 0
        raise Redis::CommandError,
              "ERR wrong number of arguments for 'xadd' command"
      end
      if args.count.odd?
        raise Redis::CommandError,
              'ERR wrong number of arguments for XADD'
      end
      with_stream_at(key) do |stream|
        stream.add id, args
        return stream.last_id
      end
    end

    def xlen(key = nil, *args)
      if key.nil? || args.count > 0
        raise Redis::CommandError,
              "ERR wrong number of arguments for 'xlen' command"
      end
      with_stream_at(key) do |stream|
        return stream.count
      end
    end

    def xrange(key = nil, start = nil, finish = nil, *options)
      if finish.nil?
        raise Redis::CommandError,
              "ERR wrong number of arguments for 'xrange' command"
      end
      with_stream_at(key) do |stream|
        return stream.range(start, finish, false, *options)
      end
    end

    def xrevrange(key = nil, finish = nil, start = nil, *options)
      if start.nil?
        raise Redis::CommandError,
              "ERR wrong number of arguments for 'xrevrange' command"
      end
      with_stream_at(key) do |stream|
        return stream.range(start, finish, true, *options)
      end
    end

    private

    def with_stream_at(key, &blk)
      with_thing_at(key, :assert_streamy, proc { Stream.new }, &blk)
    end

    def streamy?(key)
      data[key].nil? || data[key].is_a?(Stream)
    end

    def assert_streamy(key)
      unless streamy?(key)
        raise Redis::CommandError,
          'WRONGTYPE Operation against a key holding the wrong kind of value'
      end
    end
  end
end
