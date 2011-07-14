require 'forwardable'
require 'set'

class MockRedis
  class Zset
    extend Forwardable

    attr_reader :members, :scores

    def_delegator :members, :empty?

    def initialize
      @members = Set.new
      @scores  = Hash.new
    end

    def add(score, member)
      members.add(member)
      scores[member] = score
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
