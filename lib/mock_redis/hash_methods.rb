class MockRedis
  module HashMethods

    def hdel(key, field)
      assert_hashy(key)
      if @data[key].has_key?(field)
        @data[key].delete(field)
        clean_up_empties_at(key)
        1
      else
        0
      end
    end

    def hexists(key, field)
      assert_hashy(key)
      !!(@data[key] && @data[key].has_key?(field))
    end

    def hget(key, field)
      assert_hashy(key)
      (@data[key] || {})[field]
    end

    def hgetall(key)
      assert_hashy(key)
      @data[key] || {}
    end

    def hincrby(key, field, increment)
      assert_hashy(key)

      @data[key] ||= {}

      unless can_incr?(@data[key][field])
        raise RuntimeError, "ERR hash value is not an integer"
      end
      unless looks_like_integer?(increment.to_s)
        raise RuntimeError, "ERR value is not an integer or out of range"
      end

      new_value = (@data[key][field] || "0").to_i + increment.to_i
      @data[key][field] = new_value.to_s
      new_value
    end

    def hkeys(key)
      assert_hashy(key)
      (@data[key] || {}).keys
    end

    def hlen(key)
      hkeys(key).length
    end

    def hmget(key, *fields)
      unless fields.any?
        raise RuntimeError, "ERR wrong number of arguments for 'hmget' command"
      end
      fields.map{|f| hget(key, f)}
    end

    def hmset(key, *kvpairs)
      if kvpairs.none?
        raise RuntimeError, "ERR wrong number of arguments for 'hmset' command"
      elsif kvpairs.length.odd?
        raise RuntimeError, "ERR wrong number of arguments for HMSET"
      end

      kvpairs.each_slice(2) do |(k,v)|
        hset(key, k, v)
      end
      'OK'
    end

    def hset(key, field, value)
      assert_hashy(key)
      @data[key] ||= {}
      @data[key][field] = value.to_s
      true
    end

    def hsetnx(key, field, value)
      if hget(key, field)
        false
      else
        hset(key, field, value)
        true
      end
    end

    def hvals(key)
      assert_hashy(key)
      (@data[key] || {}).values
    end

    private

    def hashy?(key)
      @data[key].nil? || @data[key].kind_of?(Hash)
    end

    def assert_hashy(key)
      unless hashy?(key)
        raise RuntimeError, "ERR Operation against a key holding the wrong kind of value"
      end
    end

  end
end
