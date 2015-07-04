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
  end
end
