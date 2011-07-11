shared_examples_for "a string-only command" do
  it "raises an error for non-string values" do
    # extracting this from the RSpec description string may or may
    # not be a good idea. On the one hand, it enforces the convention
    # of putting the method name in the right place; on the other
    # hand, it's pretty magic-looking.
    method = self.example.full_description.match(/#(\w+)/).captures.first

    method_arity = @redises.mock.method(method).arity
    if method_arity < 0   # -1 comes from def foo(*args)
      args = [1, 2, 3]    # probably good enough
    else
      args = 1.upto(method_arity - 1).to_a
    end

    key = "mock-redis-test:string-only-command"

    args.unshift key

    @redises.lpush(key, 1)
    lambda do
      @redises.send(method, *args)
    end.should raise_error(RuntimeError)
  end
end
