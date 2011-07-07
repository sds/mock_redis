class MockRedis
  def initialize(*args)
    @data = {}
  end

  def keys(format)
    []
  end

  def del(*keys)
  end

  def set(key, value)
    @data[key] = value.to_s
    'OK'
  end

  def get(key)
    @data[key]
  end

end
