require 'mock_redis/assertions'
require 'mock_redis/utility_methods'
require 'mock_redis/error'

class MockRedis
  module HashMethods
    include Assertions
    include UtilityMethods

    def hdel(key, *fields)
      assert_type(key)

      with_hash_at(key) do |hash|
        orig_size = hash.size
        fields = Array(fields).flatten.map(&:to_s)

        assert_type(*fields)

        if fields.empty?
          raise Error.command_error("ERR wrong number of arguments for 'hdel' command", self)
        end

        hash.delete_if { |k, _v| fields.include?(k) }
        orig_size - hash.size
      end
    end

    def hexists(key, field)
      assert_type(key, field)

      with_hash_at(key) { |h| h.key?(field.to_s) }
    end

    def hget(key, field)
      assert_type(key, field)

      with_hash_at(key) { |h| h[field.to_s] }
    end

    def hgetall(key)
      assert_type(key)

      with_hash_at(key) { |h| h }
    end

    def hincrby(key, field, increment)
      assert_type(key, field)

      with_hash_at(key) do |hash|
        field = field.to_s
        increment = Integer(increment)
        unless can_incr?(data[key][field])
          raise Error.command_error('ERR hash value is not an integer', self)
        end

        new_value = (hash[field] || '0').to_i + increment.to_i
        hash[field] = new_value.to_s
        new_value
      end
    end

    def hincrbyfloat(key, field, increment)
      assert_type(key, field)

      with_hash_at(key) do |hash|
        field = field.to_s
        increment = Float(increment)
        unless can_incr_float?(data[key][field])
          raise Error.command_error('ERR hash value is not a float', self)
        end

        new_value = (hash[field] || '0').to_f + increment.to_f
        new_value = new_value.to_i if new_value % 1 == 0
        hash[field] = new_value.to_s
        new_value
      end
    end

    def hkeys(key)
      assert_type(key)

      with_hash_at(key, &:keys)
    end

    def hlen(key)
      assert_type(key)

      hkeys(key).length
    end

    def hmget(key, *fields)
      fields.flatten!

      assert_type(key, *fields)
      assert_has_args(fields, 'hmget')
      fields.map { |f| hget(key, f) }
    end

    def mapped_hmget(key, *fields)
      fields.flatten!

      reply = hmget(key, *fields)
      if reply.is_a?(Array)
        Hash[fields.zip(reply)]
      else
        reply
      end
    end

    def hmset(key, *kvpairs)
      if key.is_a? Array
        err_msg = 'ERR wrong number of arguments for \'hmset\' command'
        kvpairs = key[1..]
        key = key[0]
      end

      kvpairs.flatten!

      assert_type(key, *kvpairs)
      assert_has_args(kvpairs, 'hmset')

      if kvpairs.length.odd?
        raise Error.command_error(
          err_msg || "ERR wrong number of arguments for 'hmset' command",
          self
        )
      end

      kvpairs.each_slice(2) do |(k, v)|
        hset(key, k, v)
      end
      'OK'
    end

    def mapped_hmset(key, hash)
      kvpairs = hash.flatten

      assert_type(key, *kvpairs)
      assert_has_args(kvpairs, 'hmset')
      if kvpairs.length.odd?
        raise Error.command_error("ERR wrong number of arguments for 'hmset' command", self)
      end

      hmset(key, *kvpairs)
    end

    def hscan(key, cursor, opts = {})
      assert_type(key, cursor)

      opts = opts.merge(key: lambda { |x| x[0] })
      common_scan(hgetall(key).to_a, cursor, opts)
    end

    def hscan_each(key, opts = {}, &block)
      assert_type(key)

      return to_enum(:hscan_each, key, opts) unless block_given?
      cursor = 0
      loop do
        cursor, values = hscan(key, cursor, opts)
        values.each(&block)
        break if cursor == '0'
      end
    end

    def hset(key, *args)
      added = 0
      args.flatten!(1)
      assert_type(key)

      with_hash_at(key) do |hash|
        if args.length == 1 && args[0].is_a?(Hash)
          args = args[0].to_a.flatten
        end

        assert_type(*args)

        args.each_slice(2) do |field, value|
          added += 1 unless hash.key?(field.to_s)
          hash[field.to_s] = value.to_s
        end
      end
      added
    end

    def hsetnx(key, field, value)
      assert_type(key, field, value)
      if hget(key, field)
        false
      else
        hset(key, field, value)
        true
      end
    end

    def hvals(key)
      assert_type(key)

      with_hash_at(key, &:values)
    end

    private

    def with_hash_at(key, &blk)
      with_thing_at(key.to_s, :assert_hashy, proc { {} }, &blk)
    end

    def hashy?(key)
      data[key].nil? || data[key].is_a?(Hash)
    end

    def assert_hashy(key)
      unless hashy?(key)
        raise Error.wrong_type_error(self)
      end
    end
  end
end
