require 'mock_redis/assertions'
require 'mock_redis/utility_methods'
require 'mock_redis/zset'

class MockRedis
  module ZsetMethods
    include Assertions
    include UtilityMethods

    def zadd(key, score, member)
      assert_scorey(score)

      retval = !zscore(key, member)
      with_zset_at(key) {|z| z.add(score, member)}
      retval
    end

    def zcard(key)
      with_zset_at(key, &:size)
    end

    def zcount(key, min, max)
      assert_scorey(min, 'min or max')
      assert_scorey(max, 'min or max')

      with_zset_at(key) do |z|
        z.count do |score, _|
          score >= min && score <= max
        end
      end
    end

    def zincrby(key, increment, member)
      assert_scorey(increment)
      with_zset_at(key) do |z|
        old_score = z.include?(member) ? z.score(member) : 0
        new_score = old_score + increment
        z.add(new_score, member)
        new_score.to_s
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

    def zunionstore(destination, keys, options={})
      assert_has_args(keys, 'zunionstore')

      weights = options.fetch(:weights, keys.map { 1 })
      if weights.length != keys.length
        raise RuntimeError, "ERR syntax error"
      end

      aggregator = case options.fetch(:aggregate, :sum).to_s.downcase.to_sym
                   when :sum
                     proc {|a,b| [a,b].compact.reduce(&:+)}
                   when :min
                     proc {|a,b| [a,b].compact.min}
                   when :max
                     proc {|a,b| [a,b].compact.max}
                   else
                     raise RuntimeError, "ERR syntax error"
                   end

      data[destination] = with_zsets_at(*keys) do |*zsets|
        zsets.zip(weights).map do |(zset, weight)|
          zset.reduce(Zset.new) do |acc, (score, member)|
            acc.add(score * weight, member)
          end
        end.reduce do |za, zb|
          za.union(zb, &aggregator)
        end
      end
      zcard(destination)
    end

    private
    def with_zset_at(key, &blk)
      with_thing_at(key, :assert_zsety, proc {Zset.new}, &blk)
    end

    def with_zsets_at(*keys, &blk)
      if keys.length == 1
        with_zset_at(keys.first, &blk)
      else
        with_zset_at(keys.first) do |set|
          with_zsets_at(*(keys[1..-1])) do |*sets|
            blk.call(*([set] + sets))
          end
        end
      end
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

    def looks_like_float?(x)
      # ugh, exceptions for flow control.
      !!Float(x) rescue false
    end

    def assert_scorey(value, what='value')
      unless looks_like_float?(value)
        raise RuntimeError, "ERR #{what} is not a double"
      end
    end

  end
end
