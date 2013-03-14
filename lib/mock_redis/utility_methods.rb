class MockRedis
  module UtilityMethods
    private

    def with_thing_at(key, assertion, empty_thing_generator)
      begin
        send(assertion, key)
        data[key] ||= empty_thing_generator.call
        data_key_ref = data[key]
        ret = yield data[key]
        data[key] = data_key_ref if data[key].nil?
        primitive?(ret) ? ret.dup : ret
      ensure
        clean_up_empties_at(key)
      end
    end

    def primitive?(value)
      value.kind_of?(::Array) || value.kind_of?(::Hash) || value.kind_of?(::String)
    end

    def clean_up_empties_at(key)
      if data[key] && data[key].empty?
        del(key)
      end
    end

  end
end
