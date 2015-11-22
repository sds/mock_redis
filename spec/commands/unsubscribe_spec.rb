require 'spec_helper'

describe '#unsubscribe' do
  let(:default_redis_response) { ['unsubscribe', nil, 0] }

  context 'with no command args' do
    context 'and no subscribed to channels' do
      it 'returns a default Redis response' do
        expect(@redises.mock.unsubscribe).to eq(default_redis_response)
      end
    end

    context 'and subscribed to channels' do
      before :each do
        @redises.mock.publish 'foo', 1
        @redises.mock.publish 'fighters', 1
        @redises.mock.channels[:foo].subscribers << @redises.mock
        @redises.mock.channels[:fighters].subscribers << @redises.mock
      end

      it 'unsubscribes from every channel and returns last unsubscribed from channel response' do
        expect(@redises.mock.unsubscribe).to eq(['unsubscribe', 'fighters', 0])
      end
    end
  end

  context 'with more than one command args' do
    before :each do
      # NOTE: Create channels and sub to them
      @redises.mock.publish 'foo', 1
      @redises.mock.publish 'fighters', 1
    end

    context 'and no subscribed to channels' do
      it 'returns default Redis response' do
        expect(@redises.mock.unsubscribe 'foo', 'fighters').to eq(default_redis_response)
      end
    end

    context 'and subscribed to channels' do
      before :each do
        @redises.mock.channels[:foo].subscribers << @redises.mock
        @redises.mock.channels[:fighters].subscribers << @redises.mock
      end

      context 'and matching filtered channels' do
        it 'unsubscribes from the channels and returns last unsubscribed from response' do
          expect(@redises.mock.unsubscribe 'foo', 'fighters').to eq(['unsubscribe', 'fighters', 0])
        end
      end

      context 'and no matching filtered channels' do
        it 'returns default Redis response' do
          expect(@redises.mock.unsubscribe 'nirvana').to eq(default_redis_response)
        end
      end
    end
  end
end
