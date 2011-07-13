require 'mock_redis/undef_redis_methods'

class MockRedis
  class MultiDbWrapper
    include UndefRedisMethods

    def initialize(db)
      @db_index = 0

      @prototype_db = db.clone

      @databases = Hash.new {|h,k| h[k] = @prototype_db.clone}
      @databases[@db_index] = db
    end

    def respond_to?(method, include_private=false)
      super || current_db.respond_to?(method, include_private)
    end

    def method_missing(method, *args)
      current_db.send(method, *args)
    end

    def initialize_copy(source)
      super
      @databases = @databases.clone
      @databases.keys.each do |k|
        @databases[k] = @databases[k].clone
      end
    end

    # Redis commands
    def flushall
      @databases.values.each(&:flushdb)
      'OK'
    end

    def select(db_index)
      @db_index = db_index.to_i
      'OK'
    end

    private
    def current_db
      @databases[@db_index]
    end
  end
end
