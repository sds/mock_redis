RSpec.shared_examples_for 'a set-only command' do
  it 'raises an error for non-set values' do |example|
    key = 'mock-redis-test:set-only'

    method = method_from_description(example)
    args = [key, args_for_method(method)]

    @redises.set(key, 1)
    expect do
      @redises.send(method, *args)
    end.to raise_error(Redis::BaseError)
  end

  it_should_behave_like 'does not remove empty strings on error'
end
