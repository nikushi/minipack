# frozen_string_literal: true

RSpec.describe WebpackManifest::Rails do
  describe '.configuration' do
    context 'when block is not given' do
      subject { described_class.configuration }

      it { is_expected.to be_a Minipack::Configuration }
    end

    context 'when block is given' do
      it 'must yield configuration instance' do
        expect { |b| described_class.configuration(&b) }.to yield_with_args(Minipack::Configuration)
      end
    end
  end
end
