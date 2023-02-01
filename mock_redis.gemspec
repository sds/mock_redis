$LOAD_PATH << File.expand_path('lib', __dir__)
require 'mock_redis/version'

Gem::Specification.new do |s|
  s.name        = 'mock_redis'
  s.version     = MockRedis::VERSION
  s.license     = 'MIT'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Shane da Silva', 'Samuel Merritt']
  s.email       = ['shane@dasilva.io']
  s.homepage    = 'https://github.com/sds/mock_redis'
  s.summary     = 'Redis mock that just lives in memory; useful for testing.'

  s.description = <<-MSG.strip.gsub(/\s+/, ' ')
   Instantiate one with `redis = MockRedis.new` and treat it like you would a
   normal Redis object. It supports all the usual Redis operations.
  MSG

  s.metadata = {
    'bug_tracker_uri' => "#{s.homepage}/issues",
    'changelog_uri' => "#{s.homepage}/blob/v#{s.version}/CHANGELOG.md",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'homepage_uri' => s.homepage,
    'source_code_uri' => "#{s.homepage}/tree/v#{s.version}",
  }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.7'

  s.add_development_dependency 'redis', '~> 4.5.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-its', '~> 1.0'
  s.add_development_dependency 'timecop', '~> 0.9.1'
end
