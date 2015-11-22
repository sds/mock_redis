require 'spec_helper'

describe '#publish' do
  context 'with less than 2 command args (invalid)' do
    it 'raises Redis::CommandError' do
      expect { @redises.mock.publish }.to raise_error(Redis::CommandError)
      expect { @redises.mock.publish 'one' }.to raise_error(Redis::CommandError)
    end
  end

  context 'with 2 command args (valid)' do
    context 'and a non-existing `channel`' do
      it 'creates that `channel`' do
        expect { @redises.mock.publish 'foo', 'bar' }.to change { @redises.mock.channels.count }.from(0).to(1)
      end

      it 'adds a message to that `channel`' do
        @redises.mock.publish 'foo', 'bar'

        expect(@redises.mock.channels[:foo].messages.length).to eq(1)
      end
    end

    context 'and an existing `channel`' do
      it 'adds a message to that `channel`' do
        @redises.mock.publish 'foo', 'bar'

        pre_publish_count = @redises.mock.channels.count

        expect { @redises.mock.publish 'foo', 'bar' }.to change { @redises.mock.channels['foo'].messages.count }.from(1).to(2)

        expect(@redises.mock.channels.count).to eq(pre_publish_count)
      end
    end

    it 'returns subscribers count' do
      # NOTE: Hack one subscriber in
      @redises.mock.publish 'foo', 'bar'
      @redises.mock.channels[:foo].subscribers << @redises.mock.dup

      expect(@redises.mock.publish 'foo', 'bar').to eq(1)
    end
  end
end
