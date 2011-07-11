class MockRedis
  WouldBlock = Class.new(StandardError)

  def initialize(*args)
    @data = {}
  end


  def append(key, value)
    assert_stringy(key)
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
    assert_stringy(key)
    @data[key]
  end

  def getbit(key, offset)
    assert_stringy(key)

    offset_of_byte = offset / 8
    offset_within_byte = offset % 8

    # String#getbyte would be lovely, but it's not in 1.8.7.
    byte = (@data[key] || "").each_byte.drop(offset_of_byte).first

    if byte
      (byte & (2**7 >> offset_within_byte)) > 0 ? 1 : 0
    else
      0
    end
  end

  def getrange(key, start, stop)
    assert_stringy(key)
    (@data[key] || "")[start..stop]
  end

  def getset(key, value)
    retval = get(key)
    set(key, value)
    retval
  end

  def hdel(key, field)
    assert_hashy(key)
    if @data[key].has_key?(field)
      @data[key].delete(field)
      1
    else
      0
    end
  end

  def hexists(key, field)
    assert_hashy(key)
    !!(@data[key] && @data[key].has_key?(field))
  end

  def hget(key, field)
    assert_hashy(key)
    (@data[key] || {})[field]
  end

  def hkeys(key)
    assert_hashy(key)
    (@data[key] || {}).keys
  end

  def hset(key, field, value)
    assert_hashy(key)
    @data[key] ||= {}
    @data[key][field] = value.to_s
    true
  end

  def incr(key)
    incrby(key, 1)
  end

  def incrby(key, n)
    assert_stringy(key)
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
    assert_listy(key)
    (@data[key] || [])[index]
  end

  def linsert(key, position, pivot, value)
    unless %w[before after].include?(position.to_s)
      raise RuntimeError, "ERR syntax error"
    end

    assert_listy(key)
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
    assert_listy(key)
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
    assert_listy(key)
    @data[key].unshift(value.to_s) if @data[key]
    llen(key)
  end

  def lrange(key, start, stop)
    assert_listy(key)
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
    assert_listy(key)

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

  def mget(*keys)
    unless keys.length > 0
      raise RuntimeError, "ERR wrong number of arguments for 'mget' command"
    end

    keys.map do |key|
      get(key) if stringy?(key)
    end
  end

  def mset(*kvpairs)
    # a little consistency in error messages would be appreciated, Redis.
    if kvpairs.length == 0
      raise RuntimeError, "ERR wrong number of arguments for 'mset' command"
    elsif kvpairs.length.odd?
      raise RuntimeError, "ERR wrong number of arguments for MSET"
    end

    kvpairs.each_slice(2) do |(k,v)|
      set(k,v)
    end

    "OK"
  end

  def msetnx(*kvpairs)
    if kvpairs.length == 0
      raise RuntimeError, "ERR wrong number of arguments for 'msetnx' command"
    end

    if kvpairs.each_slice(2).any? {|(k,v)| exists(k)}
      0
    else
      mset(*kvpairs)
      1
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
    assert_listy(key)
    @data[key].push(value.to_s) if @data[key]
    llen(key)
  end

  def set(key, value)
    @data[key] = value.to_s
    'OK'
  end

  def setbit(key, offset, value)
    assert_stringy(key, "ERR bit is not an integer or out of range")
    retval = getbit(key, offset)

    str = @data[key] || ""

    offset_of_byte = offset / 8
    offset_within_byte = offset % 8

    if offset_of_byte >= str.bytesize
      str = zero_pad(str, offset_of_byte+1)
    end

    char_index = byte_index = offset_within_char = 0
    str.each_char do |c|
      if byte_index < offset_of_byte
        char_index += 1
        byte_index += c.bytesize
      else
        offset_within_char = byte_index - offset_of_byte
        break
      end
    end

    char = str[char_index]
    char = char.chr if char.respond_to?(:chr)  # ruby 1.8 vs 1.9
    char_as_number = char.each_byte.reduce(0) do |a, byte|
      (a << 8) + byte
    end
    char_as_number |=
      (2**((char.bytesize * 8)-1) >>
      (offset_within_char * 8 + offset_within_byte))
    str[char_index] = char_as_number.chr

    @data[key] = str
    retval
  end

  def setrange(key, offset, value)
    assert_stringy(key)
    value = value.to_s
    old_value = (@data[key] || "")

    prefix = zero_pad(old_value[0...offset], offset)
    @data[key] = prefix + value + (old_value[(offset + value.length)..-1] || "")
    @data[key].length
  end

  def strlen(key)
    assert_stringy(key)
    (@data[key] || "").bytesize
  end


  private

  def stringy?(key)
    @data[key].nil? || @data[key].kind_of?(String)
  end

  def listy?(key)
    @data[key].nil? || @data[key].kind_of?(Array)
  end

  def hashy?(key)
    @data[key].nil? || @data[key].kind_of?(Hash)
  end

  def assert_listy(key)
    unless listy?(key)
      # Not the most helpful error, but it's what redis-rb barfs up
      raise RuntimeError, "ERR Operation against a key holding the wrong kind of value"
    end
  end

  def assert_stringy(key,
      message="ERR Operation against a key holding the wrong kind of value")
    unless stringy?(key)
      raise RuntimeError, message
    end
  end

  def assert_hashy(key)
    unless hashy?(key)
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
    assert_listy(key)
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

  def zero_pad(string, desired_length)
    padding = "\000" * [(desired_length - string.length), 0].max
    string + padding
  end

end
