RSpec.shared_examples_for 'a zset-only command' do
  it 'raises an error for non-zset values' do |example|
    key = 'mock-redis-test:zset-only'

    method = method_from_description(example)
    args = args_for_method(method).unshift(key)

    @redises.set(key, 1)
    expect do
      @redises.send(method, *args)
    end.to raise_error(RuntimeError)
  end

  it_should_behave_like 'does not remove empty strings on error'
end

RSpec.shared_examples_for 'arg 1 is a score' do
  before { @_arg_index = 1 }
  it_should_behave_like 'arg N is a score'
end

RSpec.shared_examples_for 'arg 2 is a score' do
  before { @_arg_index = 2 }
  it_should_behave_like 'arg N is a score'
end

RSpec.shared_examples_for 'arg N is a score' do
  before do |example|
    key = 'mock-redis-test:zset-only'

    @method = method_from_description(example)
    @args = args_for_method(@method).unshift(key)
  end

  it 'is okay with positive ints' do
    @args[@_arg_index] = 1
    expect { @redises.send(@method, *@args) }.not_to raise_error
  end

  it 'is okay with negative ints' do
    @args[@_arg_index] = -1
    expect { @redises.send(@method, *@args) }.not_to raise_error
  end

  it 'is okay with positive floats' do
    @args[@_arg_index] = 1.5
    expect { @redises.send(@method, *@args) }.not_to raise_error
  end

  it 'is okay with negative floats' do
    @args[@_arg_index] = -1.5
    expect { @redises.send(@method, *@args) }.not_to raise_error
  end

  it 'rejects non-numbers' do
    @args[@_arg_index] = 'foo'
    expect { @redises.send(@method, *@args) }.to raise_error(RuntimeError)
  end
end
