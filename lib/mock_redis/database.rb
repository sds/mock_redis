require 'mock_redis/assertions'
require 'mock_redis/exceptions'
require 'mock_redis/hash_methods'
require 'mock_redis/list_methods'
require 'mock_redis/set_methods'
require 'mock_redis/string_methods'
require 'mock_redis/zset_methods'
require 'mock_redis/sort_method'
require 'mock_redis/indifferent_hash'
require 'mock_redis/info_method'

class MockRedis
  class Database
    include HashMethods
    include ListMethods
    include SetMethods
    include StringMethods
    include ZsetMethods
    include SortMethod
    include InfoMethod

    attr_reader :data, :expire_times

    def initialize(base, *_args)
      @base = base
      @data = MockRedis::IndifferentHash.new
      @expire_times = []
    end

    def initialize_copy(_source)
      @data = @data.clone
      @data.keys.each { |k| @data[k] = @data[k].clone }
      @expire_times = @expire_times.map(&:clone)
    end

    # Redis commands go below this line and above 'private'

    def auth(_)
      'OK'
    end

    def bgrewriteaof
      'Background append only file rewriting started'
    end

    def bgsave
      'Background saving started'
    end

    def disconnect
      nil
    end

    def connected?
      true
    end

    def dbsize
      data.keys.length
    end

    def del(*keys)
      keys = keys.flatten.map(&:to_s)
      assert_has_args(keys, 'del')

      keys.
        find_all { |key| data[key] }.
        each { |k| persist(k) }.
        each { |k| data.delete(k) }.
        length
    end

    def echo(msg)
      msg.to_s
    end

    def expire(key, seconds)
      pexpire(key, seconds.to_i * 1000)
    end

    def pexpire(key, ms)
      now_ms = (@base.now.to_r * 1000).to_i
      pexpireat(key, now_ms + ms.to_i)
    end

    def expireat(key, timestamp)
      unless looks_like_integer?(timestamp.to_s)
        raise Redis::CommandError, 'ERR value is not an integer or out of range'
      end

      pexpireat(key, timestamp.to_i * 1000)
    end

    def pexpireat(key, timestamp_ms)
      unless looks_like_integer?(timestamp_ms.to_s)
        raise Redis::CommandError, 'ERR value is not an integer or out of range'
      end

      if exists(key)
        timestamp = Rational(timestamp_ms.to_i, 1000)
        set_expiration(key, @base.time_at(timestamp))
        true
      else
        false
      end
    end

    def exists(key)
      data.key?(key)
    end

    def flushdb
      data.keys.each { |k| del(k) }
      'OK'
    end

    def keys(format = '*')
      data.keys.grep(redis_pattern_to_ruby_regex(format))
    end

    def scan(cursor, opts = {})
      count = (opts[:count] || 10).to_i
      match = opts[:match] || '*'

      keys = data.keys
      limit = cursor + count
      next_cursor = limit >= keys.length ? '0' : limit.to_s

      [next_cursor, keys[cursor..limit].grep(redis_pattern_to_ruby_regex(match))]
    end

    def lastsave
      @base.now.to_i
    end

    def persist(key)
      if exists(key) && has_expiration?(key)
        remove_expiration(key)
        true
      else
        false
      end
    end

    def ping
      'PONG'
    end

    def quit
      'OK'
    end

    def randomkey
      data.keys[rand(data.length)]
    end

    def rename(key, newkey)
      if !data.include?(key)
        raise Redis::CommandError, 'ERR no such key'
      elsif key == newkey
        raise Redis::CommandError, 'ERR source and destination objects are the same'
      end
      data[newkey] = data.delete(key)
      if has_expiration?(key)
        set_expiration(newkey, expiration(key))
        remove_expiration(key)
      end
      'OK'
    end

    def renamenx(key, newkey)
      if !data.include?(key)
        raise Redis::CommandError, 'ERR no such key'
      elsif key == newkey
        raise Redis::CommandError, 'ERR source and destination objects are the same'
      end
      if exists(newkey)
        false
      else
        rename(key, newkey)
        true
      end
    end

    def save
      'OK'
    end

    def ttl(key)
      if !exists(key)
        -2
      elsif has_expiration?(key)
        expiration(key).to_i - @base.now.to_i
      else
        -1
      end
    end

    def pttl(key)
      if !exists(key)
        -2
      elsif has_expiration?(key)
        (expiration(key).to_r * 1000).to_i - (@base.now.to_r * 1000).to_i
      else
        -1
      end
    end

    def type(key)
      if !exists(key)
        'none'
      elsif hashy?(key)
        'hash'
      elsif stringy?(key)
        'string'
      elsif listy?(key)
        'list'
      elsif sety?(key)
        'set'
      elsif zsety?(key)
        'zset'
      else
        raise ArgumentError, "Not sure how #{data[key].inspect} got in here"
      end
    end

    private

    def assert_valid_timeout(timeout)
      if !looks_like_integer?(timeout.to_s)
        raise Redis::CommandError, 'ERR timeout is not an integer or out of range'
      elsif timeout < 0
        raise Redis::CommandError, 'ERR timeout is negative'
      end
      timeout
    end

    def can_incr?(value)
      value.nil? || looks_like_integer?(value)
    end

    def can_incr_float?(value)
      value.nil? || looks_like_float?(value)
    end

    def extract_timeout(arglist)
      options = arglist.last
      if options.is_a?(Hash) && options[:timeout]
        timeout = assert_valid_timeout(options[:timeout])
        [arglist[0..-2], timeout]
      elsif options.is_a?(Integer)
        timeout = assert_valid_timeout(options)
        [arglist[0..-2], timeout]
      else
        [arglist, 0]
      end
    end

    def expiration(key)
      expire_times.find { |(_, k)| k == key.to_s }.first
    end

    def has_expiration?(key)
      expire_times.any? { |(_, k)| k == key.to_s }
    end

    def looks_like_integer?(str)
      str =~ /^-?\d+$/
    end

    def looks_like_float?(str)
      !!Float(str) rescue false
    end

    def redis_pattern_to_ruby_regex(pattern)
      Regexp.new(
        "^#{pattern}$".
        gsub(/([+|()])/, '\\\\\1').
        gsub(/([^\\])\?/, '\\1.').
        gsub(/([^\\])\*/, '\\1.*'))
    end

    def remove_expiration(key)
      expire_times.delete_if do |(_t, k)|
        key.to_s == k
      end
    end

    def set_expiration(key, time)
      remove_expiration(key)

      expire_times << [time, key.to_s]
      expire_times.sort! do |a, b|
        a.first <=> b.first
      end
    end

    def zero_pad(string, desired_length)
      padding = "\000" * [(desired_length - string.length), 0].max
      string + padding
    end

    public

    # This method isn't private, but it also isn't a Redis command, so
    # it doesn't belong up above with all the Redis commands.
    def expire_keys
      now = @base.now

      to_delete = expire_times.take_while do |(time, _key)|
        (time.to_r * 1_000).to_i <= (now.to_r * 1_000).to_i
      end

      to_delete.each do |(_time, key)|
        del(key)
      end
    end
  end
end
