require 'mock_redis/assertions'
require 'mock_redis/utility_methods'
require 'mock_redis/zset'

class MockRedis
  module ZsetMethods
    include Assertions
    include UtilityMethods

    def zadd(key, score, member)
      retval = !zscore(key, member)
      with_zset_at(key) {|z| z.add(score, member)}
      retval
    end

    def zcard(key)
      with_zset_at(key, &:size)
    end

    def zcount(key, min, max)
      with_zset_at(key) do |z|
        z.count do |score, _|
          score >= min && score <= max
        end
      end
    end

    def zrange(key, start, stop, options={})
      with_zset_at(key) do |z|
        z.sorted[start..stop].map do |(score,member)|
          if options[:with_scores] || options[:withscores]
            [member, score.to_s]
          else
            member
          end
        end.flatten
      end
    end

    def zscore(key, member)
      with_zset_at(key) do |z|
        score = z.score(member)
        score.to_s if score
      end
    end

    private
    def with_zset_at(key, &blk)
      with_thing_at(key, :assert_zsety, proc {Zset.new}, &blk)
    end

    def zsety?(key)
      data[key].nil? || data[key].kind_of?(Zset)
    end

    def assert_zsety(key)
      unless zsety?(key)
        raise RuntimeError,
        "ERR Operation against a key holding the wrong kind of value"
      end
    end

  end
end
