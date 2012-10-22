shared_examples_for "a sortable" do
  it 'returns empty array on nil' do
    @redises.sort(nil).should == []
  end

  context 'ordering' do
    it 'ascending by default' do
      @redises.sort(@key).should == ['1', '2']
    end

    it 'descending' do
      @redises.sort(@key, :order => "DESC").should == ['2', '1']
    end
  end

  context 'projections' do
    it ':get => "#"' do
      @redises.sort(@key, :get => '#').should == ['1', '2']
    end

    it ':get => "values_*"' do
      @redises.sort(@key, :get => 'mock-redis-test:values_*').should == ['a', 'b']
    end

    it ':get => ["#", "values_*"]' do
      @redises.sort(@key, :get => ['#', 'mock-redis-test:values_*']).should == [['1', 'a'], ['2', 'b']]
    end

    it ':get => "hash_*->key"' do
      @redises.sort(@key, :get => 'mock-redis-test:hash_*->key').should == ['x', 'y']
    end
  end

  context 'weights' do
    it ':by => "weight_*"' do
      @redises.sort(@key, :by => "mock-redis-test:weight_*").should == ['2', '1']
    end

    it ':order => desc' do
      @redises.sort(@key, :order => "DESC", :by => "mock-redis-test:weight_*").should == ['1', '2']
    end
  end

  context 'limit' do
    it ':limit => [offest, count]' do
      @redises.sort(@key, :limit => [0, 1]).should == ['1']
    end
  end

  context 'store' do
    it ':store => "some_bucket"' do
      @redises.sort(@key, :store => "mock-redis-test:some_bucket").should == 2
      @redises.lrange("mock-redis-test:some_bucket", 0, -1).should == ['1', '2']
    end
  end
end