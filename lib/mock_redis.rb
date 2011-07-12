require 'set'

require 'mock_redis/hash_methods'
require 'mock_redis/list_methods'
require 'mock_redis/set_methods'
require 'mock_redis/string_methods'

class MockRedis
  WouldBlock = Class.new(StandardError)

  undef_method(:type)

  def initialize(*args)
    @ds = MockRedis::DataStore.new(*args)
  end

  def respond_to?(method, include_private=false)
    super || @ds.respond_to?(method)
  end

  def method_missing(method, *args)
    @ds.expire_keys
    @ds.send(method, *args)
  end
end

class MockRedis::DataStore
  include MockRedis::HashMethods
  include MockRedis::ListMethods
  include MockRedis::SetMethods
  include MockRedis::StringMethods

  def initialize(*args)
    @data = {}
    @expire_times = []
  end


  def auth(_) 'OK' end

  def bgrewriteaof() "Background append only file rewriting started" end

  def bgsave() "Background saving started" end

  def dbsize
    @data.keys.length
  end

  def del(*keys)
    keys.
      find_all{|key| @data[key]}.
      each {|k| persist(k)}.
      each {|k| @data.delete(k)}.
      length
  end

  def echo(msg)
    msg.to_s
  end

  def expire(key, seconds)
    expireat(key, Time.now.to_i + seconds.to_i)
  end

  def expireat(key, timestamp)
    unless looks_like_integer?(timestamp.to_s)
      raise RuntimeError, "ERR value is not an integer or out of range"
    end

    if exists(key)
      set_expiration(key, Time.at(timestamp.to_i))
      true
    else
      false
    end
  end

  def exists(key)
    @data.has_key?(key)
  end

  def keys(format)
    @data.keys.grep(redis_pattern_to_ruby_regex(format))
  end

  def lastsave
    Time.now.to_i
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

  def randomkey
    @data.keys[rand(@data.length)]
  end

  def rename(key, newkey)
    if key == newkey
      raise RuntimeError, "ERR source and destination objects are the same"
    end
    @data[newkey] = @data.delete(key)
    'OK'
  end

  def renamenx(key, newkey)
    if key == newkey
      raise RuntimeError, "ERR source and destination objects are the same"
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
    if has_expiration?(key)
      (expiration(key) - Time.now).to_i
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
    else
      raise ArgumentError, "Not sure how #{@data[key].inspect} got in here"
    end
  end

  private

  def assert_valid_timeout(timeout)
    if !looks_like_integer?(timeout.to_s)
      raise RuntimeError, "ERR timeout is not an integer or out of range"
    elsif timeout < 0
      raise RuntimeError, "ERR timeout is negative"
    end
    timeout
  end

  def can_incr?(value)
    value.nil? || looks_like_integer?(value)
  end

  def extract_timeout(arglist)
    timeout = assert_valid_timeout(arglist.last)
    [arglist[0..-2], arglist.last]
  end

  def expiration(key)
    @expire_times.find {|(_,k)| k == key}.first
  end

  def has_expiration?(key)
    @expire_times.any? {|(_,k)| k == key}
  end

  def looks_like_integer?(str)
    str =~ /^-?\d+$/
  end

  def redis_pattern_to_ruby_regex(pattern)
    Regexp.new(
      "^#{pattern}$".
      gsub(/([^\\])\?/, "\\1.").
      gsub(/([^\\])\*/, "\\1.+"))
  end

  def remove_expiration(key)
    @expire_times.delete_if do |(t, k)|
      key == k
    end
  end

  def set_expiration(key, time)
    remove_expiration(key)

    @expire_times << [time, key]
    @expire_times.sort! do |a, b|
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
    now = Time.now

    to_delete = @expire_times.take_while do |(time, key)|
      time <= now
    end

    to_delete.each do |(time, key)|
      del(key)
    end

    @expire_times.slice!(0, to_delete.length)
  end
end
