# MockRedis Changelog

### 0.15.4

* Fix `zrange`/`zrevrange` to return elements with equal values in
  lexicographic order

### 0.15.3

* Fix `sadd` to return integers when adding arrays

### 0.15.2

* Fix `zrangebyscore` to work with exclusive ranges on both ends of interval

### 0.15.1

* Fix `hmget` and `mapped_hmget` to allow passing of an array of keys

### 0.15.0

* Add support for the `time` method

### 0.14.1

* Upgrade `redis` gem dependency to 3.2.x series
* Map `HDEL` field to string when given as an array

### 0.14.0

* Fix bug where SETBIT command would not correctly unset a bit
* Fix bug where a key that expired would cause another key that expired later
  to prematurely expire
* Add support to set methods to take array as argument
* Evaluate futures at the end of `#multi` blocks
* Add support for the SCAN command
* Add support for `[+/-]inf` values for min/max in ordered set commands

### 0.13.2

* Fix SMEMBERS command to not return frozen elements

### 0.13.1

* Fix bug where certain characters in keys were treated as regex characters
  rather than literals
* Add back support for legacy integer timeouts on blocking list commands

### 0.13.0

* Fix bug where SETBIT command would not correctly unset a bit
* Add support for the `connect` method
* Check that `min`/`max` parameters are floats in `zrangebyscore`,
  `zremrangebyscore`, and `zrevrangebyscore`
* Update blocking list commands to take `timeout` in an options hash
  for compatibility with `redis-rb` >= 3.0.0

### 0.12.1

* RENAME command now keeps key expiration

### 0.12.0

* Fix bug where `del` would not raise error when given empty array
* Add support for the BITCOUNT command

### 0.11.0

* Raise errors for empty arrays as arguments
* Update error messages to conform to Redis 2.8. This officially means
  `mock_redis` no *longer supports Redis 2.6 or lower*. All testing in
  TravisCI is now done against 2.8
* Update return value of TTL to return -2 if key doesn't exist
* Add support for the HINCRBYFLOAT command
* Add support for `count` parameter on SRANDMEMBER
* Add support for the PTTL command
* Improve support for negative start indices in LRANGE
* Improve support for negative start indices in LTRIM
* Allow `del` to accept arrays of keys

### 0.10.0
* Add support for :nx, :xx, :ex, :px options for SET command

### 0.9.0
* Added futures support

### 0.8.2
* Added support for Ruby 2.0.0, dropped support for Ruby 1.8.7
* Changes for compatibility with JRuby

### 0.8.1
* Fix `#pipelined` to yield self

### 0.8.0
* Fixed `watch` to return OK when passed no block
* Implemented `pexpire`, `pexpireat`
* Fixed `expire` to use millisecond precision

### 0.7.0
* Implemented `mapped_mget`, `mapped_mset`, `mapped_msetnx`
* Fixed `rpoplpush` when the `rpop` is nil

### 0.6.6
* Avoid mutation of @data from external reference
* Fix sorted set (e.g. `zadd`) with multiple score/member pairs

### 0.6.5
* Fix `zrevrange` to return an empty array on invalid range
* Fix `srandmember` spec on redis-rb 3.0.3
* Stringify keys in expiration-related commands

### 0.6.4
* Update INFO command for latest Redis 2.6 compatibility

### 0.6.3
* Treat symbols as strings for keys
* Add #reconnect method (no-op)

### 0.6.2
* Support for `connected?`, `disconnect` (no-op)
* Fix `*` in `keys` to support 0 or more

### 0.6.1
* Support default argument of `*` for keys
* Allow `MockRedis` to take a TimeClass

### 0.6.0
* Support for `#sort` (ascending and descending only)

### 0.5.5
* Support exclusive ranges in `zcount`
* List methods (`lindex`, `lrange`, `lset`, and `ltrim`) can take string indexes
* Fix typo in shared example `zset` spec
* Fix `lrange` to return `[]` when start is too large
* Update readme about spec suite compatibility

### 0.5.4
* Support `incrbyfloat` (new in Redis 2.6)
* Fix specs to pass in Redis 2.6
* Deprecated spec suite on 2.4

### 0.5.3
* Support `location` as an alias to `id` for `Sidekiq`'s benefit

### 0.5.2
* Support `watch`
* `sadd` is now Redis 2.4-compliant

### 0.5.1
* Support `MockRedis.connect`

### 0.5.0
* Support `redis-rb` >= 3.0
* Support Redis::Distributed
* Support ruby 1.9.3 in spec suite
* Support subsecond timeouts
* Support `-inf`, `+inf` in #zcount
* Return array of results from pipelined calls
* Use `debugger` instead of the deprecated `ruby-debug19`
* Fix exception handling in transaction wrappers
* Fix rename error behaviour for nonexistant keys

### 0.4.1
* bugfixes: teach various methods to correctly handle non-string values

### 0.4.0
* Support `mapped_hmset`/`mapped_hmget`
* Support `pipelined`
* Correctly handle out-of-range conditions for `zremrangebyrank` and `zrange`
* Fix off-by-one error in calculation of `ttl`

### 0.3.0
* Support hash operator (`[]`/`[]=`) as synonym of `get`/`set`
* Misc bugfixes

### 0.2.0
* Support passing a block to `#multi`.

### 0.1.2
* Fixes for 1.9.2; no functionality changes.

### 0.1.1
* Fix handling of -inf, +inf, and exclusive endpoints (e.g. "(3") in
  zrangebyscore, zrevrangebyscore, and zremrangebyscore. ("Fix" here
  means "write", as it's something that was completely forgotten the
  first time around.)

### 0.1.0
* Support `move(key, db)` to move keys between databases.

### 0.0.2
* Fix gem homepage.

### 0.0.1
Initial release.
