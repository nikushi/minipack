# frozen_string_literal: true

RSpec.describe WebpackManifest::Rails::ManifestRepository do
  describe '#add' do
    let(:repository) { described_class.new }

    it 'returns a registered manifest instance' do
      expect(repository.add(:shop, 'public/manifest.json')).to be_a WebpackManifest::Manifest
    end

    context 'when adding a first manifest' do
      before { repository.add(:shop, 'public/manifest.json') }

      it 'registers a manifest' do
        expect(repository.get(:shop)).to be_a WebpackManifest::Manifest
        expect(repository.get(:shop).path).to eq 'public/manifest.json'
      end
      it 'marks registered manifest as a default' do
        expect(repository.default).to eq repository.get(:shop)
      end
    end

    context 'when adding multiple manifests' do
      before do
        repository.add(:shop, 'public/manifest-shop.json')
        repository.add(:admin, 'public/manifest-admin.json')
      end

      it 'registers the shop manifest' do
        expect(repository.get(:shop)).to be_a WebpackManifest::Manifest
        expect(repository.get(:shop).path).to eq 'public/manifest-shop.json'
      end
      it 'marks the first manifest as a default' do
        expect(repository.default).to eq repository.get(:shop)
      end
      it 'registers the admin manifest' do
        expect(repository.get(:admin)).to be_a WebpackManifest::Manifest
        expect(repository.get(:admin).path).to eq 'public/manifest-admin.json'
      end
    end

    context 'when adding with cache enabled' do
      before { repository.add(:shop, 'public/manifest.json', cache: true) }

      it 'registers with cache enabled' do
        expect(repository.get(:shop).cache_enabled?).to eq true
      end
    end
  end

  describe '#get' do
    subject { repository.get(key) }

    let(:repository) { described_class.new }

    before { repository.add(:shop, 'public/manifest.json') }

    context 'when key is registered' do
      let(:key) { :shop }

      it 'gets a registered manifest' do
        expect(repository.get(:shop)).to be_a WebpackManifest::Manifest
        expect(repository.get(:shop).path).to eq Pathname.new('public/manifest.json')
      end
    end

    context 'when key is not registered one' do
      let(:key) { :not_exist }

      it { expect { subject }.to raise_error WebpackManifest::Rails::ManifestRepository::NotFoundError }
    end
  end
end
