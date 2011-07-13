require 'mock_redis/assertions'
require 'mock_redis/utility_methods'

class MockRedis
  module SetMethods
    include Assertions
    include UtilityMethods

    def sadd(key, member)
      with_set_at(key) {|s| !!s.add?(member.to_s)}
    end

    def scard(key)
      with_set_at(key) {|s| s.length}
    end

    def sdiff(*keys)
      assert_has_args(keys, 'sdiff')
      with_sets_at(*keys) {|*sets| sets.reduce(&:-)}.to_a
    end

    def sdiffstore(destination, *keys)
      assert_has_args(keys, 'sdiffstore')
      with_set_at(destination) do |set|
        set.merge(sdiff(*keys))
      end
      scard(destination)
    end

    def sinter(*keys)
      assert_has_args(keys, 'sinter')

      with_sets_at(*keys) do |*sets|
        sets.reduce(&:&).to_a
      end
    end

    def sinterstore(destination, *keys)
      assert_has_args(keys, 'sinterstore')
      with_set_at(destination) do |set|
        set.merge(sinter(*keys))
      end
      scard(destination)
    end

    def sismember(key, member)
      with_set_at(key) {|s| s.include?(member.to_s)}
    end

    def smembers(key)
      with_set_at(key, &:to_a)
    end

    def smove(src, dest, member)
      member = member.to_s

      with_sets_at(src, dest) do |src_set, dest_set|
        if src_set.delete?(member)
          dest_set.add(member)
          true
        else
          false
        end
      end
    end

    def spop(key)
      with_set_at(key) do |set|
        member = set.first
        set.delete(member)
        member
      end
    end

    def srandmember(key)
      with_set_at(key, &:first)
    end

    def srem(key, member)
      with_set_at(key) {|s| !!s.delete?(member.to_s)}
    end

    def sunion(*keys)
      assert_has_args(keys, 'sunion')
      with_sets_at(*keys) {|*sets| sets.reduce(&:+).to_a}
    end

    def sunionstore(destination, *keys)
      assert_has_args(keys, 'sunionstore')
      with_set_at(destination) do |dest_set|
        dest_set.merge(sunion(*keys))
      end
      scard(destination)
    end

    private
    def with_set_at(key, &blk)
      with_thing_at(key, :assert_sety, proc {Set.new}, &blk)
    end

    def with_sets_at(*keys, &blk)
      if keys.length == 1
        with_set_at(keys.first, &blk)
      else
        with_set_at(keys.first) do |set|
          with_sets_at(*(keys[1..-1])) do |*sets|
            blk.call(*([set] + sets))
          end
        end
      end
    end

    def sety?(key)
      data[key].nil? || data[key].kind_of?(Set)
    end

    def assert_sety(key)
      unless sety?(key)
        # Not the most helpful error, but it's what redis-rb barfs up
        raise RuntimeError, "ERR Operation against a key holding the wrong kind of value"
      end
    end

  end
end
