# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mock_redis/version"

Gem::Specification.new do |s|
  s.name        = "mock_redis"
  s.version     = MockRedis::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Samuel Merritt"]
  s.email       = ["spam@andcheese.org"]
  s.homepage    = "https://github.com/causes/mock_redis"
  s.summary     = %q{Redis mock that just lives in memory; useful for testing.}

  s.description = %q{Instantiate one with `redis = MockRedis.new` and treat it like you would a normal Redis object. It supports all the usual Redis operations.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "redis", "~> 2.2.1"
  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "ZenTest"
end
