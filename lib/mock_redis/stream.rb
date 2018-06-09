require 'forwardable'
require 'set'
require 'date'
require 'mock_redis/stream/id'

class MockRedis
  class Streams
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

    def add id, values
      @last_id = MockRedis::Stream::Id.new(id, min: @last_id)
      members.add [ @last_id, values ]
      @last_id.to_s
    end

    def range start, finish
      start_id = MockRedis::Stream::Id.new(start)
      finish_id = MockRedis::Stream::Id.new(finish)
      members
        .select { |m|
          (start_id <= m[0]) && (finish_id >= m[0])
        }.map { |m| [m[0].to_s, m[1]] }
    end

    def each
      members.each { |m| yield m }
    end
  end
end
