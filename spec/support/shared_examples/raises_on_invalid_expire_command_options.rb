RSpec.shared_examples_for 'raises on invalid expire command options' do |command|
  [%i[nx xx], %i[nx lt], %i[nx gt], %i[lt gt]].each do |options|
    context "with `#{options[0]}` and `#{options[1]}` options" do
      it 'raises `Redis::CommandError`' do
        expect { @mock.public_send(command, @key, 1, **options.zip([true, true]).to_h) }
          .to raise_error(
            Redis::CommandError,
            'ERR NX and XX, GT or LT options at the same time are not compatible'
          )
      end
    end

    context 'with unexpected key' do
      it 'raises `ArgumentError`' do
        expect { @mock.public_send(command, @key, 1, foo: true) }
          .to raise_error(ArgumentError)
      end
    end
  end
end
