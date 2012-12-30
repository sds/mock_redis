class MockRedis
  class IndifferentHash < Hash
    def [](key)
      super(key.to_s)
    end

    def []=(key, value)
      super(key.to_s, value)
    end
  end
end
