require 'mock_redis/assertions'

class MockRedis
  module SetMethods
    include Assertions

    def sadd(key, member)
      assert_sety(key)
      member = member.to_s

      @data[key] ||= Set.new
      if @data[key].include?(member)
        false
      else
        @data[key].add(member)
        true
      end
    end

    def scard(key)
      assert_sety(key)
      (@data[key] || Set.new).length
    end

    def sdiff(*keys)
      assert_has_args(keys, 'sdiff')

      keys.
        each {|k| assert_sety(k)}.
        map {|k| @data[k]}.
        compact.
        reduce {|a,e| a - e}.
        to_a
    end

    def sdiffstore(destination, *keys)
      assert_has_args(keys, 'sdiffstore')
      modifying_set_at(destination) do |set|
        set.merge(sdiff(*keys))
      end
      scard(destination)
    end

    def sinter(*keys)
      assert_has_args(keys, 'sinter')

      keys.
        each {|k| assert_sety(k)}.
        map {|k| @data[k] || Set.new}.
        reduce {|a,e| a & e}.
        to_a
    end

    def sinterstore(destination, *keys)
      assert_has_args(keys, 'sinterstore')
      modifying_set_at(destination) do |set|
        set.merge(sinter(*keys))
      end
      scard(destination)
    end

    def sismember(key, member)
      assert_sety(key)
      (@data[key] || Set.new).include?(member.to_s)
    end

    def smembers(key)
      assert_sety(key)
      @data[key].to_a
    end

    def smove(src, dest, member)
      member = member.to_s

      modifying_set_at(src) do |src_set|
        modifying_set_at(dest) do |dest_set|
          if src_set.delete?(member)
            dest_set.add(member)
            true
          else
            false
          end
        end
      end
    end

    private
    def modifying_set_at(key)
      assert_sety(key)
      @data[key] ||= Set.new
      retval = yield @data[key]
      clean_up_empties_at(key)
      retval
    end

    def sety?(key)
      @data[key].nil? || @data[key].kind_of?(Set)
    end

    def assert_sety(key)
      unless sety?(key)
        # Not the most helpful error, but it's what redis-rb barfs up
        raise RuntimeError, "ERR Operation against a key holding the wrong kind of value"
      end
    end

  end
end
