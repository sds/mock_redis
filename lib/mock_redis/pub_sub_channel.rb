class MockRedis
  class PubSubChannel
    attr_accessor :messages, :subscribers

    def initialize
      @messages = []
      @subscribers = []
    end

    def <<(message)
      @messages << message
    end
  end
end
