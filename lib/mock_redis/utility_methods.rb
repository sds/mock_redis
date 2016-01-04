class MockRedis
  module UtilityMethods
    private

    def with_thing_at(key, assertion, empty_thing_generator)
      send(assertion, key)
      data[key] ||= empty_thing_generator.call
      data_key_ref = data[key]
      ret = yield data[key]
      data[key] = data_key_ref if data[key].nil?
      primitive?(ret) ? ret.dup : ret
    ensure
      clean_up_empties_at(key)
    end

    def primitive?(value)
      value.is_a?(::Array) || value.is_a?(::Hash) || value.is_a?(::String)
    end

    def clean_up_empties_at(key)
      if data[key] && data[key].empty?
        del(key)
      end
    end

    def common_scan(values, cursor, opts = {})
      count = (opts[:count] || 10).to_i
      cursor = cursor.to_i
      match = opts[:match] || '*'
      key = opts[:key] || lambda { |x| x }
    
      limit = cursor + count
      next_cursor = limit >= values.length ? '0' : limit.to_s

      filtered_values = values[cursor...limit].select do |val|
        redis_pattern_to_ruby_regex(match) === key.call(val)
      end

      [next_cursor, filtered_values]
    end
  end
end
