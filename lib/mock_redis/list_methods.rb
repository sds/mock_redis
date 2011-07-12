class MockRedis
  module ListMethods
    def blpop(*args)
      lists, timeout = extract_timeout(args)
      nonempty_list = first_nonempty_list(lists)

      if nonempty_list
        [nonempty_list, lpop(nonempty_list)]
      elsif timeout > 0
        nil
      else
        raise MockRedis::WouldBlock, "Can't block forever"
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
        raise MockRedis::WouldBlock, "Can't block forever"
      end
    end

    def brpoplpush(source, destination, timeout)
      assert_valid_timeout(timeout)

      if llen(source) > 0
        rpoplpush(source, destination)
      elsif timeout > 0
        nil
      else
        raise MockRedis::WouldBlock, "Can't block forever"
      end
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

    private
    def modifying_list_at(key)
      assert_listy(key)
      retval = yield @data[key]
      clean_up_empties_at(key)
      retval
    end

    def listy?(key)
      @data[key].nil? || @data[key].kind_of?(Array)
    end

    def assert_listy(key)
      unless listy?(key)
        # Not the most helpful error, but it's what redis-rb barfs up
        raise RuntimeError, "ERR Operation against a key holding the wrong kind of value"
      end
    end

  end
end
