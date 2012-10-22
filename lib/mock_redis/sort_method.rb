require 'mock_redis/assertions'
require 'mock_redis/utility_methods'

class MockRedis
  module SortMethod
    include Assertions
    include UtilityMethods

    def sort(key, options={})
      return [] if key.nil?

      enumerable = data[key]

      return [] if enumerable.nil?

      by = options[:by]
      limit = options[:limit] || []
      store = options[:store]
      get_patterns = Array(options[:get])
      order = options[:order] || "ASC"
      direction = order.split.first

      asc_sorter = lambda { |a, b| a.first <=> b.first }.to_proc
      desc_sorter = lambda { |a, b| b.first <=> a.first }.to_proc

      sorter =
        case direction.upcase
          when "DESC"
            desc_sorter
          when "ASC"
            asc_sorter
          when "ALPHA"
            asc_sorter
          else
            raise "Invalid direction '#{direction}'"
        end

      projected = enumerable.map do |element|
        weight = by ? lookup_from_pattern(by, element) : element
        value = element

        if get_patterns.length > 0
          value = get_patterns.map do |pattern|
            pattern == "#" ? element : lookup_from_pattern(pattern, element)
          end
          value = value.first if value.length == 1
        end

        [weight, value]
      end.sort(&sorter).map(&:last)

      skip = limit.first || 0
      take = limit.last || projected.length

      sliced = projected[skip...(skip + take)] || projected

      store ? rpush(store, sliced) : sliced
    end

    private

    def lookup_from_pattern(pattern, element)
      key = pattern.sub('*', element)

      if (hash_parts = key.split('->')).length > 1
        hget hash_parts.first, hash_parts.last
      else
        get key
      end
    end

  end
end
