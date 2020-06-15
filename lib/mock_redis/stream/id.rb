class MockRedis
  class Stream
    class Id
      include Comparable

      attr_accessor :timestamp, :sequence

      def initialize(id, min: nil, sequence: 0)
        case id
        when '*'
          @timestamp = (Time.now.to_f * 1000).to_i
          @sequence = 0
          if self <= min
            @timestamp = min.timestamp
            @sequence = min.sequence + 1
          end
        when '-'
          @timestamp = @sequence = 0
        when '+'
          @timestamp = @sequence = Float::INFINITY
        else
          if id.is_a? String
            (_, @timestamp, @sequence) = id.match(/^(\d+)-?(\d+)?$/)
                                           .to_a
            if @timestamp.nil?
              raise Redis::CommandError,
                    'ERR Invalid stream ID specified as stream command argument'
            end
            @timestamp = @timestamp.to_i
          else
            @timestamp = id
          end
          @sequence = @sequence.nil? ? sequence : @sequence.to_i
          if (@timestamp == 0 && @sequence == 0)
            raise Redis::CommandError,
                  'ERR The ID specified in XADD is equal or smaller than ' \
                  'the target stream top item'
            # TOOD: Redis version 6.0.4, w redis 4.2.1 generates the following error message:
            # 'ERR The ID specified in XADD must be greater than 0-0'
          end
          if (self <= min)
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
