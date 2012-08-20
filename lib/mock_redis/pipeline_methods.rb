class MockRedis
  module PipelineMethods
    def pipelined(options = {})
      yield
      nil
    end
  end
end
