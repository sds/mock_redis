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
