class MockRedis
  module UtilityMethods
    private

    def with_thing_at(key, assertion, empty_thing_generator)
      begin
        send(assertion, key)
        data[key] ||= empty_thing_generator.call
        yield data[key]
      ensure
        clean_up_empties_at(key)
      end
    end

    def clean_up_empties_at(key)
      if data[key] && data[key].empty?
        del(key)
      end
    end

  end
end
