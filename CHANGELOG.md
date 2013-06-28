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
