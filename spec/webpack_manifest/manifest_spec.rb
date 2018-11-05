# frozen_string_literal: true

require 'spec_helper'
require 'webpack_manifest/manifest'
require 'pathname'

RSpec.describe WebpackManifest::Manifest do
  describe '.new' do
    subject { described_class.new(path, cache: cache) }

    let(:path) { 'webpack-assets.json' }
    let(:cache) { true }

    it { is_expected.to be_a described_class }
  end

  describe '#lookup!' do
    subject { described_class.new(path, cache: cache).lookup!(name) }

    let(:path) { File.expand_path('../support/files/manifest.json', __dir__) }
    let(:cache) { false }

    context 'when entry is matched by name' do
      let(:name) { 'test.js' }

      it { is_expected.to eq '/assets/web/pack/test-9a55da116417a39a9d1b.js' }
    end

    context 'when non exit name is given' do
      let(:name) { 'foo' }

      it { expect { subject }.to raise_error WebpackManifest::Manifest::MissingEntryError }
    end
  end

  describe '#load_data' do
    subject { described_class.new(path).send(:load_data) }

    context 'when given manifest is exist' do
      let(:path) { File.expand_path('../support/files/manifest.json', __dir__) }

      it { is_expected.to eq JSON.parse(File.read(path)) }
    end

    context 'when Pathname object is given' do
      let(:path) { Pathname.new(File.expand_path('../support/files/manifest.json', __dir__)) }

      it { is_expected.to eq JSON.parse(File.read(path.to_s)) }
    end

    context 'when an uri is given' do
      let(:path) { 'http://localhost:8080/packs/manifest.json' }
      let(:stub_uri) do
        instance_double('URI::HTTP',
                        scheme: 'http',
                        path: 'packs/manifest.json',
                        read: data)
      end
      let(:data) do
        { 'foo.js' => '/assets/foo-9a55da116417a39a9d1b.js.json' }.to_json
      end

      before { allow(URI).to receive(:parse).and_return(stub_uri) }

      it { is_expected.to eq JSON.parse(data) }
    end

    context 'when non-existing manifest is given' do
      let(:path) { 'not/found/path' }

      it { expect { subject }.to raise_error WebpackManifest::Manifest::FileNotFoundError }
    end
  end
end
