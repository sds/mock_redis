class MockRedis
  WouldBlock = Class.new(StandardError)

  def initialize(*args)
    @data = {}
  end


  def append(key, value)
    assert_string_or_nil_at(key)
    @data[key] ||= ""
    @data[key] << value
    @data[key].length
  end

  def auth(_) 'OK' end

  def bgrewriteaof() "Background append only file rewriting started" end

  def bgsave() "Background saving started" end

  def blpop(*args)
    lists, timeout = extract_timeout(args)
    nonempty_list = first_nonempty_list(lists)

    if nonempty_list
      [nonempty_list, lpop(nonempty_list)]
    elsif timeout > 0
      nil
    else
      raise WouldBlock, "Can't block forever"
    end
  end

  def brpop(*args)
    lists, timeout = extract_timeout(args)
    nonempty_list = first_nonempty_list(lists)

    if nonempty_list
      [nonempty_list, rpop(nonempty_list)]
    elsif timeout > 0
      nil
    else
      raise WouldBlock, "Can't block forever"
    end
  end

  def brpoplpush(source, destination, timeout)
    assert_valid_timeout(timeout)

    if llen(source) > 0
      rpoplpush(source, destination)
    elsif timeout > 0
      nil
    else
      raise WouldBlock, "Can't block forever"
    end
  end

  def del(*keys)
    keys.
      find_all{|key| @data[key]}.
      each {|k| @data.delete(k)}.
      length
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

  def getbit(key, offset)
    assert_string_or_nil_at(key)

    offset_of_byte = offset / 8
    offset_within_byte = offset % 8

    # String#getbyte would be lovely, but it's not in 1.8.7.
    byte = @data[key].each_byte.drop(offset_of_byte).first

    if byte
      (byte & (2**7 >> offset_within_byte)) > 0 ? 1 : 0
    else
      0
    end
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
    modifying_list_at(key) {|list| list.shift if list}
  end

  def lpush(key, value)
    @data[key] ||= []
    lpushx(key, value)
  end

  def lpushx(key, value)
    assert_list_or_nil_at(key)
    @data[key].unshift(value.to_s) if @data[key]
    llen(key)
  end

  def lrange(key, start, stop)
    assert_list_or_nil_at(key)
    (@data[key] || [])[start..stop]
  end

  def lrem(key, count, value)
    count = count.to_i
    value = value.to_s

    modifying_list_at(key) do |list|
      indices_with_value = (0..(llen(key) - 1)).find_all do |i|
        list[i] == value
      end

      indices_to_delete = if count == 0
                            indices_with_value.reverse
                          elsif count > 0
                            indices_with_value.take(count).reverse
                          else
                            indices_with_value.reverse.take(-count)
                          end

      indices_to_delete.each {|i| list.delete_at(i)}.length
    end
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
    modifying_list_at(key) do |list|
      list.replace(list[start..stop] || []) if list
      'OK'
    end
  end

  def rpop(key)
    modifying_list_at(key) {|list| list.pop if list}
  end

  def rpoplpush(source, destination)
    value = rpop(source)
    lpush(destination, value)
    value
  end

  def rpush(key, value)
    @data[key] ||= []
    rpushx(key, value)
  end

  def rpushx(key, value)
    assert_list_or_nil_at(key)
    @data[key].push(value.to_s) if @data[key]
    llen(key)
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

  def assert_valid_timeout(timeout)
    if !looks_like_integer?(timeout.to_s)
      raise RuntimeError, "ERR timeout is not an integer or out of range"
    elsif timeout < 0
      raise RuntimeError, "ERR timeout is negative"
    end
    timeout
  end

  def clean_up_empty_lists_at(key)
    if @data[key] && @data[key].empty?
      @data[key] = nil
    end
  end

  def can_incr?(value)
    value.nil? || looks_like_integer?(value)
  end

  def extract_timeout(arglist)
    timeout = assert_valid_timeout(arglist.last)
    [arglist[0..-2], arglist.last]
  end

  def first_nonempty_list(keys)
    keys.find{|k| llen(k) > 0}
  end

  def looks_like_integer?(str)
    str =~ /^-?\d+$/
  end

  def modifying_list_at(key)
    assert_list_or_nil_at(key)
    retval = yield @data[key]
    clean_up_empty_lists_at(key)
    retval
  end

  def redis_pattern_to_ruby_regex(pattern)
    Regexp.new(
      "^#{pattern}$".
      gsub(/([^\\])\?/, "\\1.").
      gsub(/([^\\])\*/, "\\1.+"))
  end

end
