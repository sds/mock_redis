class MockRedis
  module Error
    module_function

    def build(error_class, message, database)
      connection = database.connection
      url = "redis://#{connection[:host]}:#{connection[:port]}"
      error_class.new("#{message} (#{url})")
    end

    def wrong_type_error(database)
      build(
        Redis::WrongTypeError,
        'WRONGTYPE Operation against a key holding the wrong kind of value',
        database
      )
    end

    def syntax_error(database)
      command_error('ERR syntax error', database)
    end

    def command_error(message, database)
      build(Redis::CommandError, message, database)
    end
  end
end
