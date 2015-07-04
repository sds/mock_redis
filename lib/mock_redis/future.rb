class MockRedis
  class FutureNotReady < RuntimeError; end

  class Future
    attr_reader :command

    def initialize(command)
      @command = command
      @result_set = false
    end

    def value
      raise FutureNotReady unless @result_set
      @result
    end

    def store_result(result)
      @result_set = true
      @result = result
    end
  end
end
