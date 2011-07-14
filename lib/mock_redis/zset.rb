require 'forwardable'
require 'set'

class MockRedis
  class Zset
    include Enumerable
    extend Forwardable

    attr_reader :members, :scores

    def_delegators :members, :empty?, :size

    def initialize
      @members = Set.new
      @scores  = Hash.new
    end

    def initialize_copy(source)
      super
      @members = @members.clone
      @scores  = @scores.clone
    end

    def add(score, member)
      members.add(member)
      scores[member] = score
    end

    def each
      members.each {|m| yield score(m), m}
    end

    def score(member)
      scores[member]
    end

    def sorted
      members.map do |m|
        [score(m), m]
      end.sort_by(&:first)
    end

  end
end
