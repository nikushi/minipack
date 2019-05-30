# frozen_string_literal: true

RSpec.describe Minipack::Configuration do
  describe '.config_attr' do
    context 'when it is a root, then a value is set' do
      let(:config){ described_class.new }

      before { config.id = :admin }

      it 'can get the value set' do
        expect(config.id).to eq :admin
      end
    end

    context 'when it is a root, then a value is not set' do
      let(:config){ described_class.new }

      it 'can get the default value set' do
        expect(config.id).to eq described_class::ROOT_DEFAULT_ID
      end
    end

    context 'when it is a sub, then a value is set to the sub' do
      let(:config){ described_class.new(parent) }
      let(:parent) { described_class.new }

      before { config.id = :admin }

      it 'can get the value set' do
        expect(config.id).to eq :admin
      end
    end

    context 'when it is a sub, then a value is not set to the sub, but set to the root' do
      let(:config){ described_class.new(parent) }
      let(:parent) { described_class.new }

      before { parent.cache = true }

      it 'can get the value from the root' do
        expect(config.cache).to eq true
      end
    end

    context 'when it is a sub, then a value is not set to the sub nor the root' do
      let(:config){ described_class.new(parent) }
      let(:parent) { described_class.new }

      it 'can get the default value which is set at the root' do
        expect(config.cache).to eq false
      end
    end

    context 'when define an attr without default value' do
      subject { config_klass.config_attr :foo }

      let(:config_klass) { Class.new(described_class) }

      it 'can set a value' do
        subject
        config = config_klass.new
        config.foo = :bar
        expect(config.foo).to eq :bar
      end

      it 'responds with nil by default' do
        subject
        config = config_klass.new
        expect(config.foo).to be_nil
      end

      context 'with sub config' do
        it 'can set a value' do
          subject
          parent = config_klass.new
          config = config_klass.new(parent)
          config.foo = :bar
          expect(config.foo).to eq :bar
        end

        it 'responds with nil by default' do
          subject
          parent = config_klass.new
          config = config_klass.new(parent)
          expect(config.foo).to be_nil
        end
      end
    end

    context 'when define an attr with a default value' do
      subject { config_klass.config_attr :foo, default: :my_default }

      let(:config_klass) { Class.new(described_class) }

      it 'can set a value' do
        subject
        config = config_klass.new
        config.foo = :bar
        expect(config.foo).to eq :bar
      end

      it 'responds with the default value' do
        subject
        config = config_klass.new
        expect(config.foo).to eq :my_default
      end

      context 'with sub config' do
        it 'can set a value' do
          subject
          parent = config_klass.new
          config = config_klass.new(parent)
          config.foo = :bar
          expect(config.foo).to eq :bar
        end

        it 'responds with nil by default' do
          subject
          parent = config_klass.new
          config = config_klass.new(parent)
          expect(config.foo).to eq :my_default
        end
      end
    end
  end

  describe '#manifests' do
    subject { config.manifests }

    context 'when a single manifest is registered' do
      let(:config) do
        described_class.new.tap do |c|
          c.manifest = 'foo/bar/manifest.json'
        end
      end

      it { is_expected.to be_a Minipack::ManifestRepository }
      it 'manifest is registered as a default' do
        expect(subject.default.path).to eq 'foo/bar/manifest.json'
      end
    end

    context 'when multiple manifests are registered' do
      let(:config) do
        described_class.new.tap do |c|
          c.add :shop do |co|
            co.manifest = 'shop/manifest.json'
          end
          c.add :admin do |co|
            co.manifest = 'admin/manifest.json'
          end
        end
      end

      it { is_expected.to be_a Minipack::ManifestRepository }
      it 'count of registered manifests is expected' do
        expect(subject.all_manifests.size).to eq 2
      end
      it 'the first manifest is registered as a default' do
        expect(subject.default.path).to eq 'shop/manifest.json'
      end
      it 'the first manifest is registered' do
        expect(subject.get(:shop).path).to eq 'shop/manifest.json'
      end
      it 'the second manifest is registered' do
        expect(subject.get(:admin).path).to eq 'admin/manifest.json'
      end
    end

    context 'when it is a sub' do
      let(:config) { described_class.new(parent) }
      let(:parent) { described_class.new }

      it { expect { subject }.to raise_error described_class::Error }
    end
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

    context 'without path argument' do
      subject { config.add(:shop) }

      it 'regsters a sub configuration' do
        subject
        expect(config.children.find(:shop).id).to eq :shop
      end
    end

    context 'with a path argument' do
      subject { config.add(:shop, path) }

      let(:path) { 'public/manifest.json' }

      it 'registers a path to the sub configuration' do
        subject
        expect(config.children.find(:shop).manifest).to eq path
      end
    end

    context 'with block' do
      subject do
        config.add(:shop) do |c|
          c.manifest = 'shop/manifest.json'
        end
      end

      it 'sub configuration can be configured within the block' do
        sub_config = subject
        expect(sub_config.manifest).to eq 'shop/manifest.json'
      end
    end

    context 'when #add is called from a sub' do
      subject { config.add(:shop) }

      let(:config) { described_class.new(parent) }
      let(:parent) { described_class.new }

      it { expect { subject }.to raise_error described_class::Error }
    end
  end

  describe '#children' do
    subject { config.children.find(:shop) }

    let(:config) { described_class.new }

    before { config.add(:shop) }

    it 'looks up a sub configuration by id' do
      expect(subject).to be_a described_class
      expect(subject.id).to eq :shop
    end
  end

  describe '#leaves' do
    subject { config.leaves }

    context 'with single site' do
      let(:config) { described_class.new }

      it 'return the root configuration instance itself' do
        expect(subject.to_a).to eq [config]
      end
    end

    context 'with multiple sites' do
      let(:config) do
        described_class.new.tap do |c|
          c.add :shop
          c.add :admin
        end
      end

      it 'return the sub configurations' do
        leaves = subject
        expect(leaves.to_a.size).to eq 2
        expect(leaves.find(:shop).id).to eq :shop
        expect(leaves.find(:admin).id).to eq :admin
      end
    end
  end

  describe '#resolved_base_path' do
    subject { config.resolved_base_path }

    let(:config) { described_class.new }

    context 'when base_path is set, and it is relative' do
      before do
        config.root_path = 'app'
        config.base_path = 'frontend'
      end

      it 'base_path is recognized from root_path' do
        is_expected.to match %r{/app/frontend\z}
      end
    end

    context 'when base_path is set, and it is absolute' do
      before do
        config.root_path = 'app'
        config.base_path = '/app/frontend'
      end

      it 'base_path is a value that you set' do
        is_expected.to eq '/app/frontend'
      end
    end

    context 'when base_path is omitted' do
      before do
        config.root_path = 'app'
      end

      it 'base_path is resolved as root_path' do
        is_expected.to match %r{/app\z}
      end
    end
  end

  describe '#resolved_watched_paths' do
    subject { config.resolved_watched_paths }

    let(:config) { described_class.new }

    before do
      config.root_path = 'app'
      config.base_path = 'frontend'
    end

    context 'when the pass is relative' do
      before do
        config.watched_paths = ['package.json']
      end

      it 'is resolved based on base_dir' do
        is_expected.to all(match %r{/app/frontend/package.json})
      end
    end

    context 'when the pass is absolute' do
      before do
        config.watched_paths = ['/app/frontend/package.json']
      end

      it 'is resolved to the value you set' do
        is_expected.to eq ['/app/frontend/package.json']
      end
    end
  end
end
