RSpec.shared_examples_for 'a string-only command' do |expected_error = Redis::WrongTypeError|
  it 'raises an error for non-string values' do |example|
    key = 'mock-redis-test:string-only-command'

    method = method_from_description(example)
    args = args_for_method(method).unshift(key)

    @redises.lpush(key, 1)
    expect do
      @redises.send(method, *args)
    end.to raise_error(expected_error)
  end
end
