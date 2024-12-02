require 'redis-client'
require 'mock_redis/error'

class MockRedis
  DUMP_TYPES = RedisClient::RESP3::DUMP_TYPES

  module Assertions
    private

    def assert_has_args(args, command)
      if args.empty?
        raise Error.command_error(
          "ERR wrong number of arguments for '#{command}' command",
          self
        )
      end
    end

    def assert_type(*args)
      args.each do |arg|
        DUMP_TYPES.fetch(arg.class) do |unexpected_class|
          unless DUMP_TYPES.keys.find { |t| t > unexpected_class }
            raise TypeError, "Unsupported command argument type: #{unexpected_class}"
          end
        end
      end
    end
  end
end
