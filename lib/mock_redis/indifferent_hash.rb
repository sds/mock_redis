class MockRedis
  class IndifferentHash < Hash
    def [](key)
      super(key.to_s)
    end

    def []=(key, value)
      super(key.to_s, value)
    end

    def has_key?(key)
      super(key.to_s)
    end

    def key?(key)
      super(key.to_s)
    end
  end
end
