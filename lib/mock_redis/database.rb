require 'mock_redis/assertions'
require 'mock_redis/exceptions'
require 'mock_redis/hash_methods'
require 'mock_redis/list_methods'
require 'mock_redis/set_methods'
require 'mock_redis/string_methods'
require 'mock_redis/zset_methods'

class MockRedis
  class Database
    include HashMethods
    include ListMethods
    include SetMethods
    include StringMethods
    include ZsetMethods

    attr_reader :data, :expire_times

    def initialize(*args)
      @data = {}
      @expire_times = []
    end

    def initialize_copy(source)
      @data = @data.clone
      @data.keys.each {|k| @data[k] = @data[k].clone}
      @expire_times = @expire_times.map{|x| x.clone}
    end

    # Redis commands go below this line and above 'private'

    def auth(_) 'OK' end

    def bgrewriteaof() "Background append only file rewriting started" end

    def bgsave() "Background saving started" end

    def dbsize
      data.keys.length
    end

    def del(*keys)
      keys.
        find_all{|key| data[key]}.
        each {|k| persist(k)}.
        each {|k| data.delete(k)}.
        length
    end

    def echo(msg)
      msg.to_s
    end

    def expire(key, seconds)
      expireat(key, Time.now.to_i + seconds.to_i)
    end

    def expireat(key, timestamp)
      unless looks_like_integer?(timestamp.to_s)
        raise RuntimeError, "ERR value is not an integer or out of range"
      end

      if exists(key)
        set_expiration(key, Time.at(timestamp.to_i))
        true
      else
        false
      end
    end

    def exists(key)
      data.has_key?(key)
    end

    def flushdb
      data.keys.each {|k| del(k)}
      'OK'
    end

    def info
      astats = [
        ["2", "2699"],
        ["6", "1"],
        ["7", "1"],
        ["8", "17197"],
        ["9", "109875"],
        ["10", "94348"],
        ["11", "32580"],
        ["12", "52347"],
        ["13", "86475"],
        ["14", "58175"],
        ["15", "53408"],
        ["16", "876949"],
        ["17", "71157"],
        ["18", "5104"],
        ["19", "2705"],
        ["20", "2903"],
        ["21", "1024"],
        ["22", "2546"],
        ["23", "952"],
        ["24", "186080"],
        ["25", "611"],
        ["26", "40936"],
        ["27", "960"],
        ["28", "1323"],
        ["29", "14216"],
        ["30", "52412"],
        ["31", "21130"],
        ["32", "47959"],
        ["33", "6891"],
        ["34", "9712"],
        ["35", "3366"],
        ["36", "5737"],
        ["37", "11274"],
        ["38", "8057"],
        ["39", "2957"],
        ["40", "51200"],
        ["42", "8220"],
        ["43", "8278"],
        ["44", "6539"],
        ["45", "764"],
        ["47", "1018"],
        ["48", "19250"],
        ["49", "713"],
        ["51", "51"],
        ["53", "2"],
        ["55", "3922"],
        ["56", "153"],
        ["57", "614"],
        ["58", "1"],
        ["59", "1775"],
        ["61", "32865"],
        ["63", "2530"],
        ["64", "565"],
        ["65", "1322"],
        ["67", "1572"],
        ["69", "1421"],
        ["71", "1220"],
        ["72", "241"],
        ["73", "5432"],
        ["74", "1122"],
        ["75", "2555"],
        ["77", "1539"],
        ["78", "612"],
        ["79", "902"],
        ["81", "1678"],
        ["83", "51"],
        ["84", "612"],
        ["85", "706"],
        ["87", "410"],
        ["88", "5435"],
        ["89", "813"],
        ["90", "612"],
        ["93", "153"],
        ["94", "612"],
        ["96", "159"],
        ["97", "306"],
        ["99", "153"],
        ["101", "456"],
        ["103", "741"],
        ["105", "447"],
        ["107", "754"],
        ["109", "414"],
        ["111", "475"],
        ["113", "757"],
        ["115", "287"],
        ["117", "420"],
        ["118", "765"],
        ["119", "642"],
        ["120", "159"],
        ["121", "926"],
        ["122", "612"],
        ["123", "251"],
        ["125", "390"],
        ["127", "354"],
        ["128", "617"],
        ["129", "528"],
        ["131", "298"],
        ["132", "612"],
        ["133", "809"],
        ["135", "244"],
        ["136", "306"],
        ["137", "504"],
        ["139", "201"],
        ["141", "1124"],
        ["143", "139"],
        ["144", "159"],
        ["145", "1322"],
        ["147", "410"],
        ["149", "253"],
        ["151", "304"],
        ["153", "312"],
        ["155", "249"],
        ["157", "306"],
        ["159", "348"],
        ["161", "255"],
        ["163", "458"],
        ["165", "5"],
        ["167", "306"],
        ["168", "47"],
        ["169", "214"],
        ["171", "250"],
        ["173", "5"],
        ["177", "10"],
        ["179", "158"],
        ["181", "5"],
        ["183", "10"],
        ["185", "51"],
        ["187", "49"],
        ["191", "5"],
        ["192", "47"],
        ["193", "51"],
        ["197", "112"],
        ["199", "5"],
        ["201", "5"],
        ["203", "5"],
        ["209", "5"],
        ["213", "51"],
        ["217", "102"],
        ["225", "357"],
        ["229", "51"],
        ["233", "204"],
        ["237", "51"],
        ["239", "1"],
        ["247", "46"],
        ["255", "102"],
        [">=256", "6201"],
      ]

      {
        "allocation_stats" => astats.map {|(a,b)| "#{a}=#{b}"}.join(','),
        "aof_enabled" => "0",
        "arch_bits" => "64",
        "bgrewriteaof_in_progress" => "0",
        "bgsave_in_progress" => "0",
        "blocked_clients" => "0",
        "changes_since_last_save" => "0",
        "client_biggest_input_buf" => "0",
        "client_longest_output_list" => "0",
        "connected_clients" => "1",
        "connected_slaves" => "0",
        "db0" => "keys=8,expires=0",
        "evicted_keys" => "0",
        "expired_keys" => "0",
        "hash_max_zipmap_entries" => "512",
        "hash_max_zipmap_value" => "64",
        "keyspace_hits" => "62645",
        "keyspace_misses" => "29757",
        "last_save_time" => "1310596333",
        "loading" => "0",
        "lru_clock" => "1036434",
        "mem_fragmentation_ratio" => "2.04",
        "multiplexing_api" => "kqueue",
        "process_id" => "14508",
        "pubsub_channels" => "0",
        "pubsub_patterns" => "0",
        "redis_git_dirty" => "0",
        "redis_git_sha1" => "00000000",
        "redis_version" => "2.2.11",
        "role" => "master",
        "total_commands_processed" => "196800",
        "total_connections_received" => "4359",
        "uptime_in_days" => "0",
        "uptime_in_seconds" => "84215",
        "use_tcmalloc" => "0",
        "used_cpu_sys" => "5.54",
        "used_cpu_sys_childrens" => "0.00",
        "used_cpu_user" => "7.65",
        "used_cpu_user_childrens" => "0.02",
        "used_memory" => "931456",
        "used_memory_human" => "909.62K",
        "used_memory_rss" => "1904640",
        "vm_enabled" => "0",
      }
    end

    def keys(format)
      data.keys.grep(redis_pattern_to_ruby_regex(format))
    end

    def lastsave
      Time.now.to_i
    end

    def persist(key)
      if exists(key) && has_expiration?(key)
        remove_expiration(key)
        true
      else
        false
      end
    end

    def ping
      'PONG'
    end

    def quit
      'OK'
    end

    def randomkey
      data.keys[rand(data.length)]
    end

    def rename(key, newkey)
      if key == newkey
        raise RuntimeError, "ERR source and destination objects are the same"
      end
      data[newkey] = data.delete(key)
      'OK'
    end

    def renamenx(key, newkey)
      if key == newkey
        raise RuntimeError, "ERR source and destination objects are the same"
      end
      if exists(newkey)
        false
      else
        rename(key, newkey)
        true
      end
    end

    def save
      'OK'
    end

    def ttl(key)
      if has_expiration?(key)
        (expiration(key) - Time.now).to_i + 1
      else
        -1
      end
    end

    def type(key)
      if !exists(key)
        'none'
      elsif hashy?(key)
        'hash'
      elsif stringy?(key)
        'string'
      elsif listy?(key)
        'list'
      elsif sety?(key)
        'set'
      elsif zsety?(key)
        'zset'
      else
        raise ArgumentError, "Not sure how #{data[key].inspect} got in here"
      end
    end

    private

    def assert_valid_timeout(timeout)
      if !looks_like_integer?(timeout.to_s)
        raise RuntimeError, "ERR timeout is not an integer or out of range"
      elsif timeout < 0
        raise RuntimeError, "ERR timeout is negative"
      end
      timeout
    end

    def can_incr?(value)
      value.nil? || looks_like_integer?(value)
    end

    def extract_timeout(arglist)
      timeout = assert_valid_timeout(arglist.last)
      [arglist[0..-2], arglist.last]
    end

    def expiration(key)
      expire_times.find {|(_,k)| k == key}.first
    end

    def has_expiration?(key)
      expire_times.any? {|(_,k)| k == key}
    end

    def looks_like_integer?(str)
      str =~ /^-?\d+$/
    end

    def redis_pattern_to_ruby_regex(pattern)
      Regexp.new(
        "^#{pattern}$".
        gsub(/([^\\])\?/, "\\1.").
        gsub(/([^\\])\*/, "\\1.+"))
    end

    def remove_expiration(key)
      expire_times.delete_if do |(t, k)|
        key == k
      end
    end

    def set_expiration(key, time)
      remove_expiration(key)

      expire_times << [time, key]
      expire_times.sort! do |a, b|
        a.first <=> b.first
      end
    end

    def zero_pad(string, desired_length)
      padding = "\000" * [(desired_length - string.length), 0].max
      string + padding
    end

    public
    # This method isn't private, but it also isn't a Redis command, so
    # it doesn't belong up above with all the Redis commands.
    def expire_keys
      now = Time.now

      to_delete = expire_times.take_while do |(time, key)|
        time <= now
      end

      to_delete.each do |(time, key)|
        del(key)
      end

      expire_times.slice!(0, to_delete.length)
    end
  end
end
