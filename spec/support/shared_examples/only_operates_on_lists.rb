RSpec.shared_examples_for 'a list-only command' do
  let(:method) { |example| method_from_description(example) }
  let(:args) { args_for_method(method) }

  it 'raises an error for non-list values' do
    key = 'mock-redis-test:list-only'
    key_and_args = args.unshift(key)

    @redises.set(key, 1)

    expect do
      @redises.send(method, *key_and_args)
    end.to raise_error(defined?(default_error) ? default_error : RuntimeError)
  end

  it_should_behave_like 'does not remove empty strings on error'
end
