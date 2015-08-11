if ENV['TRAVIS']
  # When running in Travis, report coverage stats to Coveralls.
  require 'coveralls'
  Coveralls.wear!
else
  # Otherwise render coverage information in coverage/index.html and display
  # coverage percentage in the console.
  require 'simplecov'
end

require 'rspec/its'
require 'redis'
$LOAD_PATH.unshift(File.expand_path(File.join(__FILE__, '..', '..', 'lib')))
require 'mock_redis'

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..')))
Dir['spec/support/**/*.rb'].each { |x| require x }

module TypeCheckingHelper
  def method_from_description(example)
    # extracting this from the RSpec description string may or may not
    # be a good idea. On the one hand, it enforces the convention of
    # putting the method name in the right place; on the other hand,
    # it's pretty magic-looking.
    example.full_description.match(/#(\w+)/).captures.first
  end

  def args_for_method(method)
    method_arity = @redises.real.method(method).arity
    if method_arity < 0 # -1 comes from def foo(*args)
      [1, 2] # probably good enough
    else
      1.upto(method_arity - 1).to_a
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:expect, :should]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:expect, :should]
  end

  config.include(TypeCheckingHelper)

  config.before(:all) do
    @redises = RedisMultiplexer.new
  end

  config.before(:each) do
    # databases mentioned in our tests
    [1, 0].each do |db|
      @redises.send_without_checking(:select, db)
      @redises.send_without_checking(:keys, 'mock-redis-test:*').each do |key|
        @redises.send_without_checking(:del, key)
      end
    end
  end
end
