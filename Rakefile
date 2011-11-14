require 'bundler'
Bundler::GemHelper.install_tasks
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w(-fs --color)
  t.pattern = "spec/**/*_spec.rb"
end

task :default => :spec
