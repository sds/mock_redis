class MockRedis
  def initialize(*args)
  end

  def keys(format)
    []
  end

  def del(*keys)
  end

  def set(key, value)
    "OK"
  end

end
