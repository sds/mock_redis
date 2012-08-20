class MockRedis
  class PipelinedWrapper
    include UndefRedisMethods

    def respond_to?(method, include_private=false)
      super || @db.respond_to?(method)
    end

    def initialize(db)
      @db = db
      @pipelined_commands = []
      @in_pipeline = false
    end

    def initialize_copy(source)
      super
      @db = @db.clone
      @pipelined_commands = @pipelined_commands.clone
    end

    def method_missing(method, *args, &block)
      if @in_pipeline
        @pipelined_commands << [method, *args]
        nil
      else
        @db.send(method, *args, &block)
      end
    end

    def pipelined(options = {})
      @in_pipeline = true
      yield
      @in_pipeline = false
      responses = @pipelined_commands.map do |cmd|
        begin
          send(*cmd)
        rescue =>
          e
        end
      end
      @pipelined_commands = []
      responses.empty? ? nil : responses # Redis returns nil if no operations carried out. Otherwise array of results
    end
  end
end
