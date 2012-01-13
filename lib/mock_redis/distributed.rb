#require 'mock_redis/undef_redis_methods'

class MockRedis
  def pipelined(options = {})
    yield
    nil
  end
end
