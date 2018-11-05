# frozen_string_literal: true

RSpec.describe WebpackManifest::Rails::Configuration do
  describe '#cache' do
    subject { described_class.new.cache }

    it 'gets default cache setting' do
      is_expected.to eq false
    end
  end

  describe '#manifests' do
    subject { described_class.new.manifests }

    it { is_expected.to be_a WebpackManifest::Rails::ManifestRepository }
  end

  describe '#manifest=' do
    let(:config) { described_class.new }

    before do
      config.manifest = 'public/manifest.json'
    end

    it 'resigters a manifest as a default' do
      expect(config.manifests.default.path).to eq 'public/manifest.json'
    end
    it 'resigters a manifest with cache false by default' do
      expect(config.manifests.default.cache_enabled?).to eq false
    end
  end

  describe '#add' do
    let(:config) { described_class.new }

    before { config.add(:shop, 'public/manifest.json') }

    it 'registers a manifest' do
      expect(config.manifests.get(:shop)).to be_a WebpackManifest::Manifest
      expect(config.manifests.get(:shop).path).to eq 'public/manifest.json'
    end

    context 'with cache enable config' do
      before { config.cache = true }

      it 'registers a manifest with cache enabled' do
        expect(config.manifests.get(:shop).cache_enabled?).to eq true
      end
    end
  end
end
