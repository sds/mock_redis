require 'mock_redis/assertions'
require 'mock_redis/utility_methods'

require 'mock_redis/pub_sub_channel'

class MockRedis
  module PubSubMethods
    include Assertions

    def publish(channel, message)
      assert_has_args([channel, message], 'publish')

      channels[channel].messages << message
      channels[channel].subscribers.count
    end
  end
end
