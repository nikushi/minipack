# frozen_string_literal: true

RSpec.describe Webpack4r::Rails do
  describe '.configuration' do
    context 'when block is not given' do
      subject { described_class.configuration }

      it { is_expected.to be_a Webpack4r::Rails::Configuration }
    end

    context 'when block is given' do
      it 'must yield configuration instance' do
        expect { |b| described_class.configuration(&b) }.to yield_with_args(Webpack4r::Rails::Configuration)
      end
    end
  end
end
