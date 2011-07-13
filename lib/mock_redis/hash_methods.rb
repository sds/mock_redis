require 'mock_redis/assertions'
require 'mock_redis/utility_methods'

class MockRedis
  module HashMethods
    include Assertions
    include UtilityMethods

    def hdel(key, field)
      with_hash_at(key) do |hash|
        hash.delete(field) ? 1 : 0
      end
    end

    def hexists(key, field)
      with_hash_at(key) {|h| h.has_key?(field)}
    end

    def hget(key, field)
      with_hash_at(key) {|h| h[field]}
    end

    def hgetall(key)
      with_hash_at(key) {|h| h}
    end

    def hincrby(key, field, increment)
      with_hash_at(key) do |hash|
        unless can_incr?(data[key][field])
          raise RuntimeError, "ERR hash value is not an integer"
        end
        unless looks_like_integer?(increment.to_s)
          raise RuntimeError, "ERR value is not an integer or out of range"
        end

        new_value = (hash[field] || "0").to_i + increment.to_i
        hash[field] = new_value.to_s
        new_value
      end
    end

    def hkeys(key)
      with_hash_at(key, &:keys)
    end

    def hlen(key)
      hkeys(key).length
    end

    def hmget(key, *fields)
      assert_has_args(fields, 'hmget')
      fields.map{|f| hget(key, f)}
    end

    def hmset(key, *kvpairs)
      assert_has_args(kvpairs, 'hmset')
      if kvpairs.length.odd?
        raise RuntimeError, "ERR wrong number of arguments for HMSET"
      end

      kvpairs.each_slice(2) do |(k,v)|
        hset(key, k, v)
      end
      'OK'
    end

    def hset(key, field, value)
      with_hash_at(key) {|h| h[field] = value.to_s}
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
      with_hash_at(key, &:values)
    end

    private

    def with_hash_at(key, &blk)
      with_thing_at(key, :assert_hashy, proc {{}}, &blk)
    end

    def hashy?(key)
      data[key].nil? || data[key].kind_of?(Hash)
    end

    def assert_hashy(key)
      unless hashy?(key)
        raise RuntimeError, "ERR Operation against a key holding the wrong kind of value"
      end
    end

  end
end
