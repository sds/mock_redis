class BlankSlate
  instance_methods.each {|m| undef_method(m) unless m =~ /^__/ || ['inspect', 'object_id'].include?(m.to_s)}
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

    mock_retval = handle_special_cases(method, mock_retval)
    real_retval = handle_special_cases(method, real_retval)

    if (!equalish?(mock_retval, real_retval) && !mock_error && !real_error)
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
    elsif (mock_error && real_error && !equalish?(mock_error, real_error))
      raise MismatchedResponse,
        "Mock failure: raised the wrong error.\n" +
        "Redis.#{method}(#{args.inspect}) raised #{real_error.inspect}\n" +
        "MockRedis.#{method}(#{args.inspect}) raised #{mock_error.inspect}"
    end

    raise mock_error if mock_error
    mock_retval
  end

  def equalish?(a, b)
    if a == b
      true
    elsif a.is_a?(Array) && b.is_a?(Array)
      a.zip(b).all? {|(x,y)| equalish?(x,y)}
    elsif a.is_a?(Exception) && b.is_a?(Exception)
      a.class == b.class && a.message == b.message
    else
      false
    end
  end

  def mock() @mock_redis end
  def real() @real_redis end

  # Some commands require special handling due to nondeterminism in
  # the returned values.
  def handle_special_cases(method, value)
    case method.to_s
    when 'keys', 'hkeys', 'sdiff', 'sinter', 'smembers', 'sunion'
      # The order is irrelevant, but [a,b] != [b,a] in Ruby, so we
      # sort the returned values so we can ignore the order.
      value.sort if value
    else
      value
    end
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

