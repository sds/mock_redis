class MockRedis
  module MemoryMethod
    def memory(usage, key = nil, *_options)
      raise ArgumentError, "unhandled command `memory #{usage}`" if usage != 'usage'

      return nil unless @data.key?(key)

      160
    end
  end
end
