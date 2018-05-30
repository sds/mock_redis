require 'pry'

class MockRedis
  class Geohash
    DICT = '0123456789bcdefghjkmnpqrstuvwxyz'.freeze

    class << self
      def decode(hash)
        # Decode BASE32 hash to binary
        bits = hash.split('').each_with_object('') do |ch, obj|
          obj << DICT.index(ch).to_s(2).rjust(5, '0')
        end

        puts "bits: #{bits}"

        # Split bits to latitude and longitude:
        # even bits to longitude, odd bits to latitude
        lat_bits = (1...bits.length).step(2).map { |i| bits[i] }
        lng_bits = (0...bits.length).step(2).map { |i| bits[i] }

        puts "lat_bits: #{lat_bits.join}\nlng_bits: #{lng_bits.join}"

        # lat = calculate_coordinate(lat_bits, [-85.05112878, 85.05112878])
        lat = calculate_coordinate(lat_bits, [-90.0, 90.0])
        puts '----------'
        lng = calculate_coordinate(lng_bits, [-180.0, 180.0])

        [lat, lng]
      end

      private

      def calculate_coordinate(bits, range)
        p [bits, range]
        coord = nil
        bits.each do |bit|
          mid = (range[0] + range[1]) / 2
          coord = (mid + range[bit.to_i]) / 2
          p [bit, range[0], mid, range[1], coord]
          range = bit == '0' ? [range[0], mid] : [mid, range[1]]
        end
        coord
      end
    end
  end
end
