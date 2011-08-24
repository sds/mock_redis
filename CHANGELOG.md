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
