shared_examples_for "a set-only command" do
  it "raises an error for non-set values" do
    key = 'mock-redis-test:set-only'

    method = method_from_description
    args = args_for_method(method).unshift(key)

    @redises.set(key, 1)
    lambda do
      @redises.send(method, *args)
    end.should raise_error(RuntimeError)
  end
end
