require 'rspec'
require 'redis'
$LOAD_PATH.unshift(File.expand_path(File.join(__FILE__, "..", "..", "lib")))
require 'mock_redis'

class BlankSlate
  instance_methods.each {|m| undef_method(m) unless m =~ /^__/}
end

class RedisMultiplexer < BlankSlate
  MismatchedResponse = Class.new(StandardError)

  def initialize(*a)
    @mock_redis = MockRedis.new(*a)
    @real_redis = Redis.new(*a)
  end

  def method_missing(method, *args, &blk)
    mock_retval, mock_error = catch_errors { @mock_redis.send(method, *args, &blk) }
    real_retval, real_error = catch_errors { @real_redis.send(method, *args, &blk) }

    if ((mock_retval != real_retval) && !mock_error && !real_error)
      # no exceptions, just different behavior
      raise MismatchedResponse,
        "Mock failure: responses not equal.\n" +
        "Redis.#{method}(#{args.inspect}) returned #{real_retval.inspect}\n" +
        "MockRedis.#{method}(#{args.inspect}) returned #{mock_retval.inspect}\n"
    elsif (!mock_error && real_error)
      raise MismatchedResponse,
        "Mock failure: didn't raise an error when it should have.\n" +
        "Redis.#{method}(#{args.inspect}) raised #{real_error.inspect}\n" +
        "MockRedis.#{method}(#{args.inspect}) raised nothing " +
        "and returned #{mock_retval.inspect}"
    elsif (!real_error && mock_error)
      raise MismatchedResponse,
        "Mock failure: raised an error when it shouldn't have.\n" +
        "Redis.#{method}(#{args.inspect}) returned #{real_retval.inspect}\n" +
        "MockRedis.#{method}(#{args.inspect}) raised #{mock_error.inspect}"
    elsif (mock_error != real_error)
      raise MismatchedResponse,
        "Mock failure: raised the wrong error.\n" +
        "Redis.#{method}(#{args.inspect}) raised #{real_error.inspect}\n" +
        "MockRedis.#{method}(#{args.inspect}) raised #{mock_error.inspect}"
    end

    mock_retval
  end

  # Used in cleanup before() blocks.
  def send_without_checking(method, *args)
    @mock_redis.send(method, *args)
    @real_redis.send(method, *args)
  end

  def catch_errors
    begin
      retval = yield
      [retval, nil]
    rescue StandardError => e
      [nil, e]
    end
  end
end


RSpec.configure do |config|
  config.before(:all) do
    @redises = RedisMultiplexer.new
  end

  config.before(:each) do
    @redises.send_without_checking(:keys, "mock-redis-test:*").each do |key|
      @redises.send_without_checking(:del, key)
    end
  end
end
