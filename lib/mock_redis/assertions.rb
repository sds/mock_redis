class MockRedis
  module Assertions
    private

    def assert_has_args(args, command, at_least: 1)
      unless args.length >= at_least
        raise Redis::CommandError,
        "ERR wrong number of arguments for '#{command}' command"
      end
    end
  end
end
