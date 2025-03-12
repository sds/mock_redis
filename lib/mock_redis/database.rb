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
require 'mock_redis/utility_methods'
require 'mock_redis/geospatial_methods'
require 'mock_redis/stream_methods'
require 'mock_redis/connection_method'
require 'mock_redis/memory_method'

class MockRedis
  class Database
    include HashMethods
    include ListMethods
    include SetMethods
    include StringMethods
    include ZsetMethods
    include SortMethod
    include InfoMethod
    include UtilityMethods
    include GeospatialMethods
    include StreamMethods
    include ConnectionMethod
    include MemoryMethod

    attr_reader :data, :expire_times

    def initialize(base, *_args)
      @base = base
      @data = MockRedis::IndifferentHash.new
      @expire_times = []
    end

    def initialize_copy(_source)
      @data = @data.clone
      @data.each_key { |k| @data[k] = @data[k].clone }
      @expire_times = @expire_times.map(&:clone)
    end

    # Redis commands go below this line and above 'private'

    # FIXME: Current implementation of `call` does not work propetly with kwarg-options.
    # i.e. `call("EXPIRE", "foo", 40, "NX")` (which redis-rb will simply transmit to redis-server)
    # will be passed to `#expire` without keywords transformation.
    def call(*command, &_block)
      command = command[0] if command.length == 1 # allow for single array argument or multiple arguments
      public_send(command[0].downcase, *command[1..])
    end

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
    alias close disconnect
    alias disconnect! close

    def connected?
      true
    end

    def dbsize
      data.keys.length
    end

    def del(*keys)
      keys = keys.flatten.map(&:to_s)
      # assert_has_args(keys, 'del') # no longer errors in redis > v4.5

      keys.
        find_all { |key| data[key] }.
        each { |k| persist(k) }.
        each { |k| data.delete(k) }.
        length
    end
    alias unlink del

    def echo(msg)
      msg.to_s
    end

    def expire(key, seconds, nx: nil, xx: nil, lt: nil, gt: nil) # rubocop:disable Metrics/ParameterLists
      seconds = Integer(seconds)

      pexpire(key, seconds.to_i * 1000, nx: nx, xx: xx, lt: lt, gt: gt)
    end

    def pexpire(key, ms, nx: nil, xx: nil, lt: nil, gt: nil) # rubocop:disable Metrics/ParameterLists
      ms = Integer(ms)

      now, miliseconds = @base.now
      now_ms = (now * 1000) + miliseconds
      pexpireat(key, now_ms + ms.to_i, nx: nx, xx: xx, lt: lt, gt: gt)
    end

    def expireat(key, timestamp, nx: nil, xx: nil, lt: nil, gt: nil) # rubocop:disable Metrics/ParameterLists
      timestamp = Integer(timestamp)

      pexpireat(key, timestamp.to_i * 1000, nx: nx, xx: xx, lt: lt, gt: gt)
    end

    def pexpireat(key, timestamp_ms, nx: nil, xx: nil, lt: nil, gt: nil) # rubocop:disable Metrics/ParameterLists
      timestamp_ms = Integer(timestamp_ms)

      if nx && gt || gt && lt || lt && nx || nx && xx
        raise Error.command_error(
          'ERR NX and XX, GT or LT options at the same time are not compatible',
          self
        )
      end

      return false unless exists?(key)

      expiry = expiration(key)
      new_expiry = @base.time_at(Rational(timestamp_ms.to_i, 1000))

      if should_update_expiration?(expiry, new_expiry, nx: nx, xx: xx, lt: lt, gt: gt)
        set_expiration(key, new_expiry)
        true
      else
        false
      end
    end

    def exists(*keys)
      keys.count { |key| data.key?(key) }
    end

    def exists?(*keys)
      keys.each { |key| return true if data.key?(key) }
      false
    end

    def flushdb
      data.each_key { |k| del(k) }
      'OK'
    end

    def dump(key)
      value = data[key]
      value ? Marshal.dump(value) : nil
    end

    def restore(key, ttl, value, replace: false)
      if !replace && exists?(key)
        raise Error.command_error('BUSYKEY Target key name already exists.', self)
      end
      data[key] = Marshal.load(value) # rubocop:disable Security/MarshalLoad
      if ttl > 0
        pexpire(key, ttl)
      end
      'OK'
    end

    def keys(format = '*')
      data.keys.grep(redis_pattern_to_ruby_regex(format))
    end

    def scan(cursor, opts = {})
      common_scan(data.keys, cursor, opts)
    end

    def scan_each(opts = {}, &block)
      return to_enum(:scan_each, opts) unless block_given?
      cursor = 0
      loop do
        cursor, keys = scan(cursor, opts)
        keys.each(&block)
        break if cursor == '0'
      end
    end

    def lastsave
      now.first
    end

    def persist(key)
      if exists?(key) && has_expiration?(key)
        remove_expiration(key)
        true
      else
        false
      end
    end

    def ping(response = 'PONG')
      response
    end

    def quit
      'OK'
    end

    def randomkey
      data.keys[rand(data.length)]
    end

    def rename(key, newkey)
      unless data.include?(key)
        raise Error.command_error('ERR no such key', self)
      end

      if key != newkey
        data[newkey] = data.delete(key)
        if has_expiration?(key)
          set_expiration(newkey, expiration(key))
          remove_expiration(key)
        end
      end

      'OK'
    end

    def renamenx(key, newkey)
      unless data.include?(key)
        raise Error.command_error('ERR no such key', self)
      end

      if exists?(newkey)
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
      if !exists?(key)
        -2
      elsif has_expiration?(key)
        now, = @base.now
        expiration(key).to_i - now
      else
        -1
      end
    end

    def pttl(key)
      now, miliseconds = @base.now
      now_ms = now * 1000 + miliseconds

      if !exists?(key)
        -2
      elsif has_expiration?(key)
        (expiration(key).to_r * 1000).to_i - now_ms
      else
        -1
      end
    end

    def now
      current_time = @base.options[:time_class].now
      miliseconds = (current_time.to_r - current_time.to_i) * 1_000
      [current_time.to_i, miliseconds.to_i]
    end
    alias time now

    def type(key)
      if !exists?(key)
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
      elsif streamy?(key)
        'stream'
      else
        raise ArgumentError, "Not sure how #{data[key].inspect} got in here"
      end
    end

    def script(subcommand, *args); end

    def evalsha(*args); end

    def eval(*args); end

    private

    def assert_valid_timeout(timeout)
      timeout = Integer(timeout)

      if timeout < 0
        raise ArgumentError, 'time interval must not be negative'
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
      expire_times.find { |(_, k)| k == key.to_s }&.first
    end

    def has_expiration?(key)
      expire_times.any? { |(_, k)| k == key.to_s }
    end

    def looks_like_integer?(str)
      !!Integer(str) rescue false
    end

    def looks_like_float?(str)
      !!Float(str) rescue false
    end

    def should_update_expiration?(expiry, new_expiry, nx:, xx:, lt:, gt:) # rubocop:disable Metrics/ParameterLists
      return false if nx && expiry || xx && !expiry
      return false if lt && expiry && new_expiry > expiry
      return false if gt && (!expiry || new_expiry < expiry)

      true
    end

    def redis_pattern_to_ruby_regex(pattern)
      Regexp.new(
        "^#{pattern}$".
        gsub(/([+|(){}])/, '\\\\\1').
        gsub(/(?<!\\)\?/, '\\1.').
        gsub(/([^\\])\*/, '\\1.*')
      )
    end

    def remove_expiration(key)
      expire_times.delete_if do |(_t, k)|
        key.to_s == k
      end
    end

    def set_expiration(key, time)
      remove_expiration(key)
      found = expire_times.each_with_index.to_a.bsearch { |item, _| item.first >= time }
      index = found ? found.last : -1
      expire_times.insert(index, [time, key.to_s])
    end

    def zero_pad(string, desired_length)
      padding = "\000" * [(desired_length - string.length), 0].max
      string + padding
    end

    public

    # This method isn't private, but it also isn't a Redis command, so
    # it doesn't belong up above with all the Redis commands.
    def expire_keys
      now_sec, miliseconds = now
      now_ms = now_sec * 1_000 + miliseconds

      to_delete = expire_times.take_while do |(time, _key)|
        (time.to_r * 1_000).to_i <= now_ms
      end

      to_delete.each do |(_time, key)|
        del(key)
      end
    end
  end
end
