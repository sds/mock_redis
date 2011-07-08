class MockRedis
  def initialize(*args)
    @data = {}
  end

  def del(*keys)
    keys.each {|k| @data.delete(k) }
  end

  def decr(key)
    decrby(key, 1)
  end

  def decrby(key, n)
    incrby(key, -n)
  end

  def exists(key)
    @data.has_key?(key)
  end

  def get(key)
    assert_string_or_nil_at(key)
    @data[key]
  end

  def incr(key)
    incrby(key, 1)
  end

  def incrby(key, n)
    assert_string_or_nil_at(key)
    unless can_incr?(@data[key])
      raise RuntimeError, "ERR value is not an integer or out of range"
    end

    unless looks_like_integer?(n.to_s)
      raise RuntimeError, "ERR value is not an integer or out of range"
    end

    new_value = @data[key].to_i + n.to_i
    @data[key] = new_value.to_s
    # for some reason, redis-rb doesn't return this as a string.
    new_value
  end

  def keys(format)
    @data.keys.grep(redis_pattern_to_ruby_regex(format))
  end

  def lindex(key, index)
    assert_list_or_nil_at(key)
    (@data[key] || [])[index]
  end

  def linsert(key, position, pivot, value)
    unless %w[before after].include?(position.to_s)
      raise RuntimeError, "ERR syntax error"
    end

    assert_list_or_nil_at(key)
    return 0 unless @data[key]

    pivot_position = (0..llen(key) - 1).find do |i|
      @data[key][i] == pivot.to_s
    end

    return -1 unless pivot_position

    insertion_index = if position.to_s == 'before'
                        pivot_position
                      else
                        pivot_position + 1
                      end

    @data[key].insert(insertion_index, value.to_s)
    llen(key)
  end

  def llen(key)
    assert_list_or_nil_at(key)
    (@data[key] || []).length
  end

  def lpop(key)
    assert_list_or_nil_at(key)
    value = (@data[key] || []).shift
    clean_up_empty_lists_at(key)
    value
  end

  def lpush(key, value)
    assert_list_or_nil_at(key)

    @data[key] ||= []
    @data[key].unshift(value.to_s)
    llen(key)
  end

  def lpushx(key, value)
    assert_list_or_nil_at(key)
    return 0 unless @data[key]
    lpush(key, value)
  end

  def lrange(key, start, stop)
    assert_list_or_nil_at(key)
    (@data[key] || [])[start..stop]
  end

  def lrem(key, count, value)
    assert_list_or_nil_at(key)
    count = count.to_i
    value = value.to_s

    indices_with_value = (0..(llen(key) - 1)).find_all do |i|
      @data[key][i] == value
    end

    indices_to_delete = if count == 0
                          indices_with_value.reverse
                        elsif count > 0
                          indices_with_value.take(count).reverse
                        else
                          indices_with_value.reverse.take(-count)
                        end

    indices_to_delete.each {|i| @data[key].delete_at(i)}
    clean_up_empty_lists_at(key)
    indices_to_delete.length
  end

  def lset(key, index, value)
    assert_list_or_nil_at(key)

    unless @data[key]
      raise RuntimeError, "ERR no such key"
    end

    unless (0...llen(key)).include?(index)
      raise RuntimeError, "ERR index out of range"
    end

    @data[key][index] = value.to_s
    'OK'
  end

  def ltrim(key, start, stop)
    assert_list_or_nil_at(key)
    @data[key] = @data[key][start..stop]
    clean_up_empty_lists_at(key)
    'OK'
  end

  def set(key, value)
    @data[key] = value.to_s
    'OK'
  end

  private

  def assert_list_or_nil_at(key)
    unless @data[key].nil? || @data[key].kind_of?(Array)
      # Not the most helpful error, but it's what redis-rb barfs up
      raise RuntimeError, "ERR Operation against a key holding the wrong kind of value"
    end
  end

  def assert_string_or_nil_at(key)
    unless @data[key].nil? || @data[key].kind_of?(String)
      raise RuntimeError, "ERR Operation against a key holding the wrong kind of value"
    end
  end

  def clean_up_empty_lists_at(key)
    if @data[key] && @data[key].empty?
      @data[key] = nil
    end
  end

  def can_incr?(value)
    value.nil? || looks_like_integer?(value)
  end

  def looks_like_integer?(str)
    str =~ /^-?\d+$/
  end

  def redis_pattern_to_ruby_regex(pattern)
    Regexp.new(
      "^#{pattern}$".
      gsub(/([^\\])\?/, "\\1.").
      gsub(/([^\\])\*/, "\\1.+"))
  end

end
