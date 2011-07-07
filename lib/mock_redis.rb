class MockRedis
  def initialize(*args)
    @data = {}
  end

  def del(*keys)
  end

  def exists(key)
    @data.has_key?(key)
  end

  def get(key)
    @data[key]
  end

  def keys(format)
    @data.keys.grep(redis_pattern_to_ruby_regex(format))
  end

  def set(key, value)
    @data[key] = value.to_s
    'OK'
  end

  private

  def redis_pattern_to_ruby_regex(pattern)
    Regexp.new(
      "^#{pattern}$".
      gsub(/([^\\])\?/, "\\1.").
      gsub(/([^\\])\*/, "\\1.+"))
  end

end
