RSpec.describe Minipack do
  it "has a version number" do
    expect(Minipack::VERSION).not_to be nil
  end

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

  describe '.after_initialize' do
    subject { described_class.after_initialize { } }

    after { described_class.after_initialize_hooks.clear }

    it { expect { subject }.to change { described_class.after_initialize_hooks.size }.by(1) }
  end
end
