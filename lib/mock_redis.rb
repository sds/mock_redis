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
    []
  end

  def set(key, value)
    @data[key] = value.to_s
    'OK'
  end

end
