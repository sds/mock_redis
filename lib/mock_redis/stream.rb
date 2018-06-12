require 'forwardable'
require 'set'
require 'date'
require 'mock_redis/stream/id'

# TODO:
#
#   * xrange (see https://github.com/antirez/redis/issues/5006)
#   * xread
#   * xgroup
#   * xreadgroup
#   * xack
#   * xpending
#   * xclaim
#   * xinfo
#   * xtrim
#   * xdel
#
# For details of these commands see https://redis.io/topics/streams-intro

class MockRedis
  class Stream
    include Enumerable
    extend Forwardable

    attr_accessor :members

    def_delegators :members, :empty?

    def initialize
      @members = Set.new
      @last_id = nil
    end

    def last_id
      @last_id.to_s
    end

    def add(id, values)
      @last_id = MockRedis::Stream::Id.new(id, min: @last_id)
      members.add [@last_id, values.map(&:to_s)]
      @last_id.to_s
    end

    def range(start, finish, *options)
      opts = {}
      options.each_slice(2).map { |pair| opts[pair[0].downcase] = pair[1].to_i }
      start_id = MockRedis::Stream::Id.new(start)
      finish_id = MockRedis::Stream::Id.new(finish, sequence: Float::INFINITY)
      items = members
              .select { |m| (start_id <= m[0]) && (finish_id >= m[0]) }
              .map { |m| [m[0].to_s, m[1]] }
      return items.first(opts['count'].to_i) if opts.key?('count')
      items
    end

    def each
      members.each { |m| yield m }
    end
  end
end
