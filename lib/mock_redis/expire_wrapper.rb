require 'mock_redis/undef_redis_methods'

class MockRedis
  class ExpireWrapper
    include UndefRedisMethods

    def respond_to?(method, include_private=false)
      super || @db.respond_to?(method)
    end

    def initialize(db)
      @db = db
    end

    def method_missing(method, *args)
      @db.expire_keys
      @db.send(method, *args)
    end

    def initialize_copy(source)
      super
      @db = @db.clone
    end
  end
end
