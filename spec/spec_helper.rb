require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'

  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end
end

require 'rspec/its'
require 'redis'
$LOAD_PATH.unshift(File.expand_path(File.join(__FILE__, '..', '..', 'lib')))
require 'mock_redis'
require 'timecop'

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..')))
Dir['spec/support/**/*.rb'].sort.each { |x| require x }

module TypeCheckingHelper
  def method_from_description(example)
    # extracting this from the RSpec description string may or may not
    # be a good idea. On the one hand, it enforces the convention of
    # putting the method name in the right place; on the other hand,
    # it's pretty magic-looking.
    example.full_description.match(/#(\w+)/).captures.first
  end

  def args_for_method(method)
    # using parameters instead of arity because arity cannot properly account for keyword vs positional arguments
    # when it is negative arity
    parameters = @redises.real.method(method).parameters
    base_parameters = parameters.count{ |type, _| type == :req || type == :opt }
    rest_params = parameters.count{ |type, _| type == :rest }
    total_params = (rest_params * 2) + base_parameters

    (1..(total_params - 1)).to_a
  end
end

RSpec.configure do |config|
  config.expect_with(:rspec) do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with(:rspec) do |mocks|
    mocks.syntax = :expect
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!

  config.include(TypeCheckingHelper)

  config.before(:all) do
    @redises = RedisMultiplexer.new(url: 'redis://localhost:6379')
  end

  config.before(:each) do
    # databases mentioned in our tests
    [1, 0].each do |db|
      @redises.send_without_checking(:select, db)
      keys = @redises.send_without_checking(:keys, 'mock-redis-test:*')
      next unless keys.is_a?(Enumerable)

      keys.each do |key|
        @redises.send_without_checking(:del, key)
      end
    end
    @redises._gsub_clear
  end

  # By default, all the specs are considered to be compatible with redis 6,
  # specs for redis 7 should be marked with `redis: 7.0` tag.
  config.run_all_when_everything_filtered = true
  config.filter_run_excluding redis: 7.0
end
