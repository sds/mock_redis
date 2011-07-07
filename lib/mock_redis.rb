class MockRedis
  def initialize(*args)
    @data = {}
  end

  def del(*keys)
    keys.each {|k| @data.delete(k) }
  end

  def exists(key)
    @data.has_key?(key)
  end

  def get(key)
    @data[key]
  end

  def incr(key)
    unless can_incr?(@data[key])
      raise RuntimeError, "ERR value is not an integer"
    end

    new_value = @data[key].to_i + 1
    @data[key] = new_value.to_s
    # for some reason, redis-rb doesn't return this as a string.
    new_value
  end

  def keys(format)
    @data.keys.grep(redis_pattern_to_ruby_regex(format))
  end

  def set(key, value)
    @data[key] = value.to_s
    'OK'
  end

  private

  def can_incr?(value)
    value.nil? || looks_like_integer?(value)
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

end
