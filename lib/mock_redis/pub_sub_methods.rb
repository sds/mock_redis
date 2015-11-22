require 'mock_redis/assertions'
require 'mock_redis/utility_methods'

require 'mock_redis/pub_sub_channel'

require 'pry'

class MockRedis
  # http://redis.io/topics/pubsub
  module PubSubMethods
    include Assertions

    # http://redis.io/commands/psubscribe
    def psubscribe(*patterns)
      assert_has_args(patterns, 'psubscribe')
    end

    # http://redis.io/commands/publish
    def publish(channel, message)
      assert_has_args([channel, message], 'publish')

      channels[channel].messages << message
      channels[channel].subscribers.count
    end

    # http://redis.io/commands/pubsub
    def pubsub(sub_command, *args)
    end

    # http://redis.io/commands/punsubscribe
    def punsubscribe(*patterns)
      assert_has_args(patterns, 'publish')
    end

    # http://redis.io/commands/subscribe
    def subscribe(*sub_channels)
      assert_has_args(sub_channels, 'subscribe')

      sub_channels.each do |sub_channel|
        channels[sub_channel].subscribers << client
      end
    end

    # http://redis.io/commands/unsubscribe
    def unsubscribe(*unsub_channels)
      channels_to_unsub = if !unsub_channels.nil? && unsub_channels.any?
                            channels.select do |key, value|
                              unsub_channels.include?(key) && subscribed?(value)
                            end
                          else
                            channels
                          end

      if channels_to_unsub.none?
        # When nothing to unsub, return standard Redis response
        ['unsubscribe', nil, 0]
      else
        # Create a new array of standard Redis responses and return only the last popped response
        channels_to_unsub.collect do |channel_name, channel|
          channel.subscribers.delete(self)
          ['unsubscribe', channel_name, 0]
        end.pop
      end
    end

    private

    def subscribed?(channel)
      channel.subscribers.any? do |subscriber|
        subscriber.client.connection_id == client.connection_id
      end
    end
  end
end
