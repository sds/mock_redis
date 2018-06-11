require 'mock_redis/assertions'
require 'mock_redis/utility_methods'
require 'mock_redis/stream'

class MockRedis
  module StreamMethods
    include Assertions
    include UtilityMethods

    def xadd(key, id, *args)
      with_stream_at(key) do |stream|
        stream.add id, args
        return stream.last_id
      end
    end

    def xlen(key)
      with_stream_at(key) do |stream|
        return stream.count
      end
    end

    def xrange(key, start, finish, *options)
      with_stream_at(key) do |stream|
        return stream.range(start, finish, *options)
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
