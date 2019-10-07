require 'spec_helper'

describe MockRedis::HashMethods do
  subject { MockRedis.new }

  context 'all keys treated as strings' do
    before do
      subject.hmset(:foo, [:bar, :bas])
      subject.hmset(1, [:free, :bird])
    end

    it { expect(subject.hgetall('foo')).to eq 'bar' => 'bas' }
    it { expect(subject.hgetall(:foo)).to eq 'bar' => 'bas' }
    it { expect(subject.hgetall(1)).to eq 'free' => 'bird' }
    it { expect(subject.hgetall('1')).to eq 'free' => 'bird' }

    context 'keys are deletable' do
      it { expect(subject.del(1)).to eq 1 }
      it { expect(subject.del('1')).to eq 1 }
      it { expect(subject.del(:foo)).to eq 1 }
      it { expect(subject.del('foo')).to eq 1 }
    end
  end
end
