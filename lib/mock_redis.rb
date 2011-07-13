require 'set'

require 'mock_redis/assertions'
require 'mock_redis/data_store'
require 'mock_redis/expire_wrapper'
require 'mock_redis/transaction_wrapper'
require 'mock_redis/undef_redis_methods'

class MockRedis
  include UndefRedisMethods

  def initialize(*args)
    @ds = TransactionWrapper.new(
      ExpireWrapper.new(
        DataStore.new(*args)))
  end

  def respond_to?(method, include_private=false)
    super || @ds.respond_to?(method, include_private)
  end

  def method_missing(method, *args)
    @ds.send(method, *args)
  end
end
