require 'set'

require 'mock_redis/assertions'
require 'mock_redis/database'
require 'mock_redis/distributed'
require 'mock_redis/expire_wrapper'
require 'mock_redis/multi_db_wrapper'
require 'mock_redis/transaction_wrapper'
require 'mock_redis/undef_redis_methods'

class MockRedis
  include UndefRedisMethods

  attr_reader :options

  DEFAULTS = {
     :scheme => "redis",
     :host => "127.0.0.1",
     :port => 6379,
     :path => nil,
     :timeout => 5.0,
     :password => nil,
     :db => 0,
  }

  def initialize(*args)
    @options = _parse_options(args.first)    

    args << self

    @db = TransactionWrapper.new(
      ExpireWrapper.new(
        MultiDbWrapper.new(
          Database.new(*args))))
  end

  def id
    "redis://#{self.host}:#{self.port}/0"
  end

  def call(command, &block)
     self.send(*command)
  end

  def host
    self.options[:host]
  end

  def port
    self.options[:port]
  end

  def respond_to?(method, include_private=false)
    super || @db.respond_to?(method, include_private)
  end

  def method_missing(method, *args, &block)
    @db.send(method, *args, &block)
  end

  def initialize_copy(source)
    super
    @db = @db.clone
  end


  protected

  def _parse_options(options)
    return {} if options.nil?
    
    defaults = DEFAULTS.dup

    url = options[:url] || ENV["REDIS_URL"]

    # Override defaults from URL if given
    if url
      require "uri"

      uri = URI(url)

      if uri.scheme == "unix"
        defaults[:path]   = uri.path
      else
        # Require the URL to have at least a host
        raise ArgumentError, "invalid url" unless uri.host

        defaults[:scheme]   = uri.scheme
        defaults[:host]     = uri.host
        defaults[:port]     = uri.port if uri.port
        defaults[:password] = uri.password if uri.password
        defaults[:db]       = uri.path[1..-1].to_i if uri.path
      end
    end

    options = defaults.merge(options)

    if options[:path]
      options[:scheme] = "unix"
      options.delete(:host)
      options.delete(:port)
    else
      options[:host] = options[:host].to_s
      options[:port] = options[:port].to_i
    end

    options[:timeout] = options[:timeout].to_f
    options[:db] = options[:db].to_i

    options
  end

end
