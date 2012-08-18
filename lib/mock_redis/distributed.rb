class MockRedis
  def pipelined(options = {})
    yield
    []
  end
end
