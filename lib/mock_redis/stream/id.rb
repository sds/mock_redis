class MockRedis
  class Stream
    class Id
      include Comparable

      attr_accessor :timestamp, :sequence

      def initialize(id, min: nil)
        case id
        when '*'
          @timestamp = DateTime.now.strftime('%Q').to_i
          @sequence = 0
          if self <= min
            @timestamp = min.timestamp
            @sequence = min.sequence + 1
          end
        when '-'
          @timestamp = @sequenct = 0
        when '+'
          @timestamp = @sequenct = Float::INFINITY
        else
          @timestamp, @sequence = id.split('-').map(&:to_i)
          @sequence = 0 if @sequence.nil?
          if self <= min
            raise Redis::CommandError,
                  'ERR The ID specified in XADD is equal or smaller than ' \
                  'the target stream top item'
          end
        end
      end

      def to_s
        "#{@timestamp}-#{@sequence}"
      end

      def <=>(other)
        return 1 if other.nil?
        return @sequence <=> other.sequence if @timestamp == other.timestamp
        @timestamp <=> other.timestamp
      end
    end
  end
end
