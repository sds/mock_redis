require 'pry'

class MockRedis
  module GeospatialMethods
    LNG_RANGE = (-180..180)
    LAT_RANGE = (-85.05112878..85.05112878)
    STEP = 26

    def geoadd(key, *args)
      points = parse_points(args)

      scored_points = points.map do |point|
        score = encode(point[:lng], point[:lat])
        [score.to_s, point[:key]]
      end

      zadd(key, scored_points)
    end

    def geopos(key, *args)
      return [] if zcard(key).zero?

      args.map do |member|
        score = zscore(key, member)&.to_i
        next nil unless score
        lng, lat = decode(score)
        lng = format_decoded_coord(lng)
        lat = format_decoded_coord(lat)
        [lng, lat]
      end
    end

    private

    def parse_points(args)
      points = args.each_slice(3).to_a

      if points.last.size != 3
        raise Redis::CommandError,
          "ERR wrong number of arguments for 'geoadd' command"
      end

      points.map do |point|
        parse_point(point)
      end
    end

    def parse_point(point)
      lng = Float(point[0])
      lat = Float(point[1])

      unless LNG_RANGE.include?(lng) && LAT_RANGE.include?(lat)
        lng = format('%.6f', lng)
        lat = format('%.6f', lat)
        raise Redis::CommandError,
          "ERR invalid longitude,latitude pair #{lng},#{lat}"
      end

      { key: point[2], lng: lng, lat: lat }
    rescue ArgumentError
      raise Redis::CommandError, 'ERR value is not a valid float'
    end

    # Returns ZSET score for passed coordinates
    def encode(lng, lat)
      lat_offset = (lat - LAT_RANGE.min) / (LAT_RANGE.max - LAT_RANGE.min)
      lng_offset = (lng - LNG_RANGE.min) / (LNG_RANGE.max - LNG_RANGE.min)

      lat_offset *= (1 << STEP)
      lng_offset *= (1 << STEP)

      interleave(lat_offset.to_i, lng_offset.to_i)
    end

    def interleave(x, y)
      b = [0x5555555555555555, 0x3333333333333333, 0x0F0F0F0F0F0F0F0F,
           0x00FF00FF00FF00FF, 0x0000FFFF0000FFFF]
      s = [1, 2, 4, 8, 16]

      x = (x | (x << s[4])) & b[4]
      y = (y | (y << s[4])) & b[4]

      x = (x | (x << s[3])) & b[3]
      y = (y | (y << s[3])) & b[3]

      x = (x | (x << s[2])) & b[2]
      y = (y | (y << s[2])) & b[2]

      x = (x | (x << s[1])) & b[1]
      y = (y | (y << s[1])) & b[1]

      x = (x | (x << s[0])) & b[0]
      y = (y | (y << s[0])) & b[0]

      x | (y << 1)
    end

    # Decodes ZSET score to coordinates pair
    def decode(bits)
      hash_sep = deinterleave(bits)

      lat_scale = LAT_RANGE.max - LAT_RANGE.min
      lng_scale = LNG_RANGE.max - LNG_RANGE.min

      ilato = hash_sep & 0xFFFFFFFF # cast int64 to int32 to get lat part of deinterleaved hash
      ilngo = hash_sep >> 32        # shift over to get lng part of hash

      # Calculate approximate area
      lat_min =  LAT_RANGE.min + (ilato * 1.0 / (1 << STEP)) * lat_scale
      lat_max =  LAT_RANGE.min + ((ilato + 1) * 1.0 / (1 << STEP)) * lat_scale
      lng_min =  LNG_RANGE.min + (ilngo * 1.0 / (1 << STEP)) * lng_scale
      lng_max =  LNG_RANGE.min + ((ilngo + 1) * 1.0 / (1 << STEP)) * lng_scale

      lng = (lng_min + lng_max) / 2
      lat = (lat_min + lat_max) / 2

      [lng, lat]
    end

    def deinterleave(bits)
      b = [0x5555555555555555, 0x3333333333333333, 0x0F0F0F0F0F0F0F0F,
           0x00FF00FF00FF00FF, 0x0000FFFF0000FFFF, 0x00000000FFFFFFFF]
      s = [0, 1, 2, 4, 8, 16]

      x = bits
      y = bits >> 1

      x = (x | (x >> s[0])) & b[0]
      y = (y | (y >> s[0])) & b[0]

      x = (x | (x >> s[1])) & b[1]
      y = (y | (y >> s[1])) & b[1]

      x = (x | (x >> s[2])) & b[2]
      y = (y | (y >> s[2])) & b[2]

      x = (x | (x >> s[3])) & b[3]
      y = (y | (y >> s[3])) & b[3]

      x = (x | (x >> s[4])) & b[4]
      y = (y | (y >> s[4])) & b[4]

      x = (x | (x >> s[5])) & b[5]
      y = (y | (y >> s[5])) & b[5]

      x | (y << 32)
    end

    def format_decoded_coord(coord)
      coord = format('%.17f', coord)
      l = 1
      l += 1 while coord[-l] == '0'
      coord = coord[0..-l]
      coord[-1] == '.' ? coord[0..-2] : coord
    end
  end
end
