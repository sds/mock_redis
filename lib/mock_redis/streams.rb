require 'forwardable'
require 'set'

class MockRedis
  class Streams
    include Enumerable
    extend Forwardable

    attr_accessor :members

    def_delegators :members, :empty?

    def initialize
      @members = Set.new
      @last_timestamp = 0
      @last_i = 0
    end

    def last_id
      "#{@last_timestamp}-#{@last_i}"
    end

    def add id
      t, i = if id == '*'
               [ DateTime.now.strftime('%Q').to_i, 0 ]
             else
               id.split('-').map(&:to_i)
             end
      i = 0 if i.nil?
      if t <= @last_timestamp && i <= @last_i
        raise Redis::CommandError,
              'ERR The ID specified in XADD is equal or smaller than the ' \
              'target stream top item'
      end
      @last_timestamp = t
      @last_i = i
    end

    def each
      members.each { |m| yield m }
    end
  end
end