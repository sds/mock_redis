RSpec.shared_examples_for 'does not remove empty strings on error' do
  it 'does not remove empty strings on error' do |example|
    key = 'mock-redis-test:not-a-string'

    method = method_from_description(example)
    args = [key, args_for_method(method)]

    @redises.set(key, '')
    expect do
      @redises.send(method, *args)
    end.to raise_error(defined?(default_error) ? default_error : Redis::BaseError)
    expect(@redises.get(key)).to eq('')
  end
end
