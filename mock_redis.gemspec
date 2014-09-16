$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'mock_redis/version'

Gem::Specification.new do |s|
  s.name        = 'mock_redis'
  s.version     = MockRedis::VERSION
  s.license     = 'MIT'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Causes Engineering', 'Samuel Merritt']
  s.email       = ['eng@causes.com']
  s.homepage    = 'https://github.com/causes/mock_redis'
  s.summary     = 'Redis mock that just lives in memory; useful for testing.'

  s.description = <<-EOS.strip.gsub(/\s+/, ' ')
   Instantiate one with `redis = MockRedis.new` and treat it like you would a
   normal Redis object. It supports all the usual Redis operations.
  EOS

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'redis', '~> 3.0.0'
  s.add_development_dependency 'rspec', '~> 3.1.0'
  s.add_development_dependency 'rspec-its', '~> 1.0'
end
