require 'date'
require 'mock_redis/assertions'
require 'mock_redis/utility_methods'
require 'mock_redis/streams'

class MockRedis
  module StreamsMethods
    include Assertions
    include UtilityMethods

    def xadd(key, id, *args)
      with_streams_at(key) do |stream|
        stream.add id
        return stream.last_id
      end
    end

    private

    def with_streams_at(key, &blk)
      with_thing_at(key, :assert_streamsy, proc { Streams.new }, &blk)
    end

    def streamsy?(key)
      data[key].nil? || data[key].is_a?(Streams)
    end

    def assert_streamsy(key)
      unless streamsy?(key)
        raise Redis::CommandError,
          'WRONGTYPE Operation against a key holding the wrong kind of value'
      end
    end
  end
end
