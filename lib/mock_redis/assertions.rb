class MockRedis
  module Assertions
    private

    def assert_has_args(args, command)
      unless args.any?
        raise RuntimeError,
        "ERR wrong number of arguments for '#{command}' command"
      end
    end
      
  end
end
