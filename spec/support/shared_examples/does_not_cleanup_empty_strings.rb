RSpec.shared_examples_for 'does not remove empty strings on error' do
  let(:method) { |example| method_from_description(example) }
  let(:args) { args_for_method(method) }
  let(:error) { defined?(default_error) ? default_error : Redis::WrongTypeError }

  it 'does not remove empty strings on error' do
    key = 'mock-redis-test:not-a-string'
    key_and_args = args.unshift(key)

    @redises.set(key, '')
    expect do
      @redises.send(method, *key_and_args)
    end.to raise_error(*error)
    expect(@redises.get(key)).to eq('')
  end
end
