class MockRedis
  module SetMethods

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
      unless keys.any?
        raise RuntimeError, "ERR wrong number of arguments for 'sdiff' command"
      end

      keys.
        each {|k| assert_sety(k)}.
        map {|k| @data[k]}.
        compact.
        reduce {|a,e| a - e}.
        to_a
    end

    def sdiffstore(destination, *keys)
      unless keys.any?
        raise RuntimeError, "ERR wrong number of arguments for 'sdiffstore' command"
      end
      @data[destination] = Set.new(sdiff(*keys))
      scard(destination)
    end

    def smembers(key)
      assert_sety(key)
      @data[key].to_a
    end


    private
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
