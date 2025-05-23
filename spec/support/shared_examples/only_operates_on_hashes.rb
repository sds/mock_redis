RSpec.shared_examples_for 'a hash-only command' do
  it 'raises an error for non-hash values' do |example|
    key = 'mock-redis-test:hash-only'

    method = method_from_description(example)
    args = args_for_method(method).unshift(key)

    @redises.set(key, 1)
    expect do
      @redises.send(method, *args)
    end.to raise_error(Redis::WrongTypeError)
  end

  it_should_behave_like 'does not remove empty strings on error'
end
