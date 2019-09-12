# frozen_string_literal: true

require 'spec_helper'
require 'pathname'

RSpec.describe Minipack::Manifest do
  describe '.new' do
    subject { described_class.new(path, cache: cache) }

    let(:path) { 'webpack-assets.json' }
    let(:cache) { true }

    it { is_expected.to be_a described_class }
  end

  describe '#lookup_pack_with_chunks!' do
    subject { described_class.new(path, cache: false).lookup_pack_with_chunks!(name, type: type) }

    let(:path) { File.expand_path('../support/files/manifest.json', __dir__) }
    let(:type) { nil }

    context 'with name with ext' do
      let(:name) { 'application.js' }

      it do
        expected = Minipack::Manifest::ChunkGroup.new(
                     %w(/packs/vendors~application~bootstrap-c20632e7baf2c81200d3.chunk.js
                        /packs/vendors~application-e55f2aae30c07fb6d82a.chunk.js
                        /packs/application-k344a6d59eef8632c9d1.js),
                   )
        is_expected.to eq expected
      end
    end

    context 'with name without ext' do
      let(:name) { 'application' }
      let(:type) { 'js' }

      it do
        expected = Minipack::Manifest::ChunkGroup.new(
            %w(/packs/vendors~application~bootstrap-c20632e7baf2c81200d3.chunk.js
                        /packs/vendors~application-e55f2aae30c07fb6d82a.chunk.js
                        /packs/application-k344a6d59eef8632c9d1.js),
            )
        is_expected.to eq expected
      end
    end

    context 'when non exist name is given' do
      let(:name) { 'foo.js' }

      it { expect { subject }.to raise_error Minipack::Manifest::MissingEntryError }
    end
  end

  describe '#lookup!' do
    subject { described_class.new(path, cache: cache).lookup!(name) }

    let(:path) { File.expand_path('../support/files/manifest.json', __dir__) }
    let(:cache) { false }

    context 'when entry is matched by name' do
      let(:name) { 'test.js' }

      it { is_expected.to eq Minipack::Manifest::Entry.new('/assets/web/pack/test-9a55da116417a39a9d1b.js') }
    end

    context 'when non exit name is given' do
      let(:name) { 'foo' }

      it { expect { subject }.to raise_error Minipack::Manifest::MissingEntryError }
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

      it { expect { subject }.to raise_error Minipack::Manifest::FileNotFoundError }
    end
  end
end
