require 'mock_redis/assertions'
require 'mock_redis/utility_methods'

class MockRedis
  module ListMethods
    include Assertions
    include UtilityMethods

    def blmove(source, destination, wherefrom, whereto, options = {})
      options = { :timeout => options } if options.is_a?(Integer)
      timeout = options.is_a?(Hash) && options[:timeout] || 0
      assert_valid_timeout(timeout)

      if llen(source) > 0
        lmove(source, destination, wherefrom, whereto)
      elsif timeout > 0
        nil
      else
        raise MockRedis::WouldBlock, "Can't block forever"
      end
    end

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

    def brpoplpush(source, destination, timeout: 0)
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
      with_list_at(key) { |l| l[index.to_i] }
    end

    def linsert(key, position, pivot, value)
      unless %w[before after].include?(position.to_s)
        raise Error.command_error('ERR syntax error', self)
      end

      assert_listy(key)
      return 0 unless data[key]

      pivot_position = (0..llen(key) - 1).find do |i|
        data[key][i] == pivot.to_s
      end

      return -1 unless pivot_position

      insertion_index = if position.to_s == 'before'
                          pivot_position
                        else
                          pivot_position + 1
                        end

      data[key].insert(insertion_index, value.to_s)
      llen(key)
    end

    def llen(key)
      with_list_at(key, &:length)
    end

    def lmpop(*keys, **options)
      keys.each do |key|
        assert_listy(key)
      end

      modifier = options.is_a?(Hash) && options[:modifier]&.to_s&.downcase || 'left'
      count = (options.is_a?(Hash) && options[:count]) || 1

      unless %w[left right].include?(modifier)
        raise Redis::CommandError, 'ERR syntax error'
      end

      keys.each do |key|
        record_count = llen(key)
        next if record_count.zero?

        values = [count, record_count].min.times.map do
          modifier == 'left' ? with_list_at(key, &:shift) : with_list_at(key, &:pop)
        end

        return [key, values]
      end

      nil
    end

    def lmove(source, destination, wherefrom, whereto)
      assert_listy(source)
      assert_listy(destination)

      wherefrom = wherefrom.to_s.downcase
      whereto = whereto.to_s.downcase

      assert_where_field(wherefrom, 'where_source')
      assert_where_field(whereto, 'where_destination')

      value = wherefrom == 'left' ? lpop(source) : rpop(source)
      (whereto == 'left' ? lpush(destination, value) : rpush(destination, value)) unless value.nil?
      value
    end

    def lpop(key, count = nil)
      return with_list_at(key, &:shift) if count.nil?

      record_count = llen(key)
      return nil if record_count.zero?

      [record_count, count].min.times.map { with_list_at(key, &:shift) }
    end

    def lpush(key, values)
      values = [values] unless values.is_a?(Array)
      assert_has_args(values, 'lpush')
      with_list_at(key) { |l| values.each { |v| l.unshift(v.to_s) } }
      llen(key)
    end

    def lpushx(key, value)
      value = [value] unless value.is_a?(Array)
      if value.empty?
        raise Error.command_error("ERR wrong number of arguments for 'lpushx' command", self)
      end
      assert_listy(key)
      return 0 unless list_at?(key)
      lpush(key, value)
    end

    def lrange(key, start, stop)
      start = start.to_i
      with_list_at(key) { |l| start < l.size ? l[[start, -l.length].max..stop.to_i] : [] }
    end

    def lrem(key, count, value)
      count = Integer(count)
      value = value.to_s

      with_list_at(key) do |list|
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

        indices_to_delete.each { |i| list.delete_at(i) }.length
      end
    end

    def lset(key, index, value)
      assert_listy(key)

      unless list_at?(key)
        raise Error.command_error('ERR no such key', self)
      end

      index = index.to_i
      unless (0...llen(key)).cover?(index)
        raise Error.command_error('ERR index out of range', self)
      end

      data[key][index] = value.to_s
      'OK'
    end

    def ltrim(key, start, stop)
      with_list_at(key) do |list|
        list&.replace(list[[start.to_i, -list.length].max..stop.to_i] || [])
        'OK'
      end
    end

    def rpop(key, count = nil)
      return with_list_at(key) { |list| list&.pop } if count.nil?

      record_count = llen(key)
      return nil if record_count.zero?

      [record_count, count].min.times.map { with_list_at(key, &:pop) }
    end

    def rpoplpush(source, destination)
      value = rpop(source)
      lpush(destination, value) unless value.nil?
      value
    end

    def rpush(key, values)
      values = [values] unless values.is_a?(Array)
      assert_has_args(values, 'rpush')
      with_list_at(key) { |l| values.each { |v| l.push(v.to_s) } }
      llen(key)
    end

    def rpushx(key, value)
      value = [value] unless value.is_a?(Array)
      if value.empty?
        raise Error.command_error("ERR wrong number of arguments for 'rpushx' command", self)
      end
      assert_listy(key)
      return 0 unless list_at?(key)
      rpush(key, value)
    end

    private

    def list_at?(key)
      data[key] && listy?(key)
    end

    def with_list_at(key, &blk)
      with_thing_at(key, :assert_listy, proc { [] }, &blk)
    end

    def listy?(key)
      data[key].nil? || data[key].is_a?(Array)
    end

    def assert_listy(key)
      unless listy?(key)
        # Not the most helpful error, but it's what redis-rb barfs up
        raise Error.wrong_type_error(self)
      end
    end

    def assert_where_field(where, argument_name)
      unless %w[left right].include?(where)
        raise ArgumentError, "#{argument_name} must be 'LEFT' or 'RIGHT'"
      end
    end

    def first_nonempty_list(keys)
      keys.find { |k| llen(k) > 0 }
    end
  end
end
