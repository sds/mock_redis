require 'mock_redis/undef_redis_methods'

class MockRedis
  class ExpireWrapper
    include UndefRedisMethods

    def respond_to?(method, include_private=false)
      super || @ds.respond_to?(method)
    end

    def initialize(ds)
      @ds = ds
    end

    def method_missing(method, *args)
      @ds.expire_keys
      @ds.send(method, *args)
    end
  end
end
