RSpec.shared_examples_for 'a list-only command' do
  let(:method) { |example| method_from_description(example) }
  let(:args) { args_for_method(method) }
  let(:error) { defined?(default_error) ? default_error : RuntimeError }

  it 'raises an error for non-list values' do
    key = 'mock-redis-test:list-only'
    key_and_args = args.unshift(key)

    @redises.set(key, 1)

    expect do
      @redises.send(method, *key_and_args)
    end.to raise_error(*error)
  end

  include_examples 'does not remove empty strings on error'
end
