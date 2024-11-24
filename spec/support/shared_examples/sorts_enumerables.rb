RSpec.shared_examples_for 'a sortable' do
  it 'returns empty array on nil' do
    expect { @redises.sort(nil) }.to raise_error(TypeError)
  end

  context 'ordering' do
    it 'orders ascending by default' do
      expect(@redises.sort(@key)).to eq(%w[1 2])
    end

    it 'orders by descending when specified' do
      expect(@redises.sort(@key, :order => 'DESC')).to eq(%w[2 1])
    end
  end

  context 'projections' do
    it 'projects element when :get is "#"' do
      expect(@redises.sort(@key, :get => '#')).to eq(%w[1 2])
    end

    it 'projects through a key pattern' do
      expect(@redises.sort(@key, :get => 'mock-redis-test:values_*')).to eq(%w[a b])
    end

    it 'projects through a key pattern and reflects element' do
      expect(@redises.sort(@key, :get => ['#', 'mock-redis-test:values_*']))
        .to eq([%w[1 a], %w[2 b]])
    end

    it 'projects through a hash key pattern' do
      expect(@redises.sort(@key, :get => 'mock-redis-test:hash_*->key')).to eq(%w[x y])
    end
  end

  context 'weights' do
    it 'weights by projecting through a key pattern' do
      expect(@redises.sort(@key, :by => 'mock-redis-test:weight_*')).to eq(%w[2 1])
    end

    it 'weights by projecting through a key pattern and a specific order' do
      expect(@redises.sort(@key, :order => 'DESC', :by => 'mock-redis-test:weight_*'))
        .to eq(%w[1 2])
    end
  end

  context 'limit' do
    it 'only returns requested window in the enumerable' do
      expect(@redises.sort(@key, :limit => [0, 1])).to eq(['1'])
    end
  end

  context 'store' do
    it 'stores into another key' do
      expect(@redises.sort(@key, :store => 'mock-redis-test:some_bucket')).to eq(2)
      expect(@redises.lrange('mock-redis-test:some_bucket', 0, -1)).to eq(%w[1 2])
    end
  end
end
