# frozen_string_literal: true

RSpec.describe WebpackManifest::Rails::Helper do
  let(:helper){ ActionView::Base.new }
  let(:manifest_path) { File.expand_path('../../support/files/manifest.json', __dir__) }
  let(:configuration) do
    WebpackManifest::Rails::Configuration.new.tap do |c|
      c.cache = false
      c.manifest = manifest_path
    end
  end

  before do
    @original = WebpackManifest::Rails.configuration
    WebpackManifest::Rails.configuration = configuration
  end
  after { WebpackManifest::Rails.configuration = @original }

  describe '#asset_bundle_path' do
    context 'given existing *.js entry name' do
      subject { helper.asset_bundle_path('item_group_editor.js') }

      it 'returns actual file name' do
        is_expected.to eq '/packs/item_group_editor-857e5bfa272e71b6384046f68ba29d44.js'
      end
    end

    context 'given existing *.css entry name' do
      subject { helper.asset_bundle_path('item_group_editor.css') }

      it 'returns actual file name' do
        is_expected.to eq '/packs/item_group_editor-5d7c7164b8a0a9d675fad9ab410eaa8d.css'
      end
    end

    context 'with multiple manifests registration and with manifest: option' do
      subject { helper.asset_bundle_path('admin-application.css', manifest: :admin) }

      let(:manifest_admin_path) { File.expand_path('../../support/files/manifest-admin.json', __dir__) }
      let(:configuration) do
        WebpackManifest::Rails::Configuration.new.tap do |c|
          c.cache = false
          c.add :shop, manifest_path
          c.add :admin, manifest_admin_path
        end
      end

      it 'returns actual file name' do
        is_expected.to eq '/packs/admin/admin-application-5d7c7164b8a0a9d675fad9ab410eaa8d.css'
      end
    end

    context 'given non-existing entry name' do
      subject do
        -> { helper.asset_bundle_path('not_found.js') }
      end

      it 'raises' do
        is_expected.to raise_error WebpackManifest::Manifest::MissingEntryError
      end
    end
  end

  describe '#javascript_bundle_tag' do
    context 'given existing *.js entry name' do
      subject { helper.javascript_bundle_tag('item_group_editor') }

      it 'renders a nice <script> tag' do
        is_expected.to eq '<script src="/packs/item_group_editor-857e5bfa272e71b6384046f68ba29d44.js"></script>'
      end
    end

    context 'given existing *.js entry name with async' do
      subject { helper.javascript_bundle_tag('item_group_editor', async: true) }

      it 'renders a nice <script> tag' do
        is_expected.to eq '<script src="/packs/item_group_editor-857e5bfa272e71b6384046f68ba29d44.js" async="async"></script>'
      end
    end

    context 'given existing *.js entry name symbol' do
      subject { helper.javascript_bundle_tag(:item_group_editor) }

      it 'renders a nice <script> tag' do
        is_expected.to eq '<script src="/packs/item_group_editor-857e5bfa272e71b6384046f68ba29d44.js"></script>'
      end
    end

    context 'with multiple manifests registration and with manifest: option' do
      subject { helper.javascript_bundle_tag('admin-application', manifest: :admin) }

      let(:manifest_admin_path) { File.expand_path('../../support/files/manifest-admin.json', __dir__) }
      let(:configuration) do
        WebpackManifest::Rails::Configuration.new.tap do |c|
          c.cache = false
          c.add :shop, manifest_path
          c.add :admin, manifest_admin_path
        end
      end

      it 'renders a nice <script> tag' do
        is_expected.to eq '<script src="/packs/admin/admin-application-5d7c7164b8a0a9d675fad9ab410eaa8d.js"></script>'
      end
    end

    context 'given non-existing *.js entry name' do
      subject do
        -> { helper.javascript_bundle_tag('not_found') }
      end

      it 'raises' do
        is_expected.to raise_error WebpackManifest::Manifest::MissingEntryError
      end
    end
  end

  describe '#stylesheet_bundle_tag' do
    context 'given existing *.css entry name' do
      subject { helper.stylesheet_bundle_tag('item_group_editor') }

      it 'renders a nice <link> tag' do
        is_expected.to eq '<link rel="stylesheet" media="screen" href="/packs/item_group_editor-5d7c7164b8a0a9d675fad9ab410eaa8d.css" />'
      end
    end

    context 'given existing *.css entry symbol' do
      subject { helper.stylesheet_bundle_tag(:item_group_editor) }

      it 'renders a nice <link> tag' do
        is_expected.to eq '<link rel="stylesheet" media="screen" href="/packs/item_group_editor-5d7c7164b8a0a9d675fad9ab410eaa8d.css" />'
      end
    end

    context 'with multiple manifests registration and with manifest: option' do
      subject { helper.stylesheet_bundle_tag('admin-application', manifest: :admin) }

      let(:manifest_admin_path) { File.expand_path('../../support/files/manifest-admin.json', __dir__) }
      let(:configuration) do
        WebpackManifest::Rails::Configuration.new.tap do |c|
          c.cache = false
          c.add :shop, manifest_path
          c.add :admin, manifest_admin_path
        end
      end

      it 'renders a nice <link> tag' do
        is_expected.to eq '<link rel="stylesheet" media="screen" href="/packs/admin/admin-application-5d7c7164b8a0a9d675fad9ab410eaa8d.css" />'
      end
    end

    context 'given non-existing *.css entry name' do
      subject do
        -> { helper.stylesheet_bundle_tag('not_found') }
      end

      it 'raises' do
        is_expected.to raise_error WebpackManifest::Manifest::MissingEntryError
      end
    end
  end

  describe '#image_bundle_tag' do
    context 'given existing *.png entry name' do
      subject { helper.image_bundle_tag('union-ok.png') }

      it 'renders a nice <img> tag' do
        is_expected.to eq '<img src="/packs/union-ok-857e5bfa272e71b6384046f68ba29d44.png" />'
      end
    end

    context 'with multiple manifests registration and with manifest: option' do
      subject { helper.image_bundle_tag('admin-icon.png', manifest: :admin) }

      let(:manifest_admin_path) { File.expand_path('../../support/files/manifest-admin.json', __dir__) }
      let(:configuration) do
        WebpackManifest::Rails::Configuration.new.tap do |c|
          c.cache = false
          c.add :shop, manifest_path
          c.add :admin, manifest_admin_path
        end
      end

      it 'renders a nice <img> tag' do
        is_expected.to eq '<img src="/packs/admin/admin-icon-5d7c7164b8a0a9d675fad9ab410eaa8d.png" />'
      end
    end

    context 'given non-existing *.png entry name' do
      subject do
        -> { helper.image_bundle_tag('not_found.png') }
      end

      it 'raises' do
        is_expected.to raise_error WebpackManifest::Manifest::MissingEntryError
      end
    end

    context 'given without extname' do
      subject do
        -> { helper.image_bundle_tag('not_found') }
      end

      it 'raises' do
        is_expected.to raise_error WebpackManifest::Manifest::MissingEntryError
      end
    end
  end
end
