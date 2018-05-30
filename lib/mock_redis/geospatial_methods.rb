class MockRedis
  module GeospatialMethods
    LNG_RANGE = (-180..180)
    LAT_RANGE = (-85.05112878..85.05112878)
    STEP = 26

    def geoadd(key, *args)
      points = parse_points(args)

      scored_points = points.map do |point|
        score = calculate_zset_score(point[:lng], point[:lat])
        [score.to_s, point[:key]]
      end

      zadd(key, scored_points)
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

    def calculate_zset_score(lng, lat)
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
  end
end
