class MockRedis
  def pipelined(options = {})
    yield
    nil
  end
end
