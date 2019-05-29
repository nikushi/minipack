# frozen_string_literal: true

RSpec.describe Minipack::Helper do
  let(:helper){ ActionView::Base.new }
  let(:manifest_path) { File.expand_path('../../support/files/manifest.json', __dir__) }
  let(:configuration) do
    Minipack::Configuration.new.tap do |c|
      c.cache = false
      c.manifest = manifest_path
    end
  end

  before do
    @original = Minipack.configuration
    Minipack.configuration = configuration
  end
  after { Minipack.configuration = @original }

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
        Minipack::Configuration.new.tap do |c|
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
        is_expected.to raise_error Minipack::Manifest::MissingEntryError
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
        Minipack::Configuration.new.tap do |c|
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
        is_expected.to raise_error Minipack::Manifest::MissingEntryError
      end
    end
  end

  describe '#javascript_bundles_with_chunks_tag' do
    context 'given existing *.js entry name' do
      subject { helper.javascript_bundles_with_chunks_tag('application') }

      it 'renders tags for chunk assets' do
        is_expected.to eq(
          %(<script src="/packs/vendors~application~bootstrap-c20632e7baf2c81200d3.chunk.js"></script>\n) +
          %(<script src="/packs/vendors~application-e55f2aae30c07fb6d82a.chunk.js"></script>\n) +
          %(<script src="/packs/application-k344a6d59eef8632c9d1.js"></script>),
        )
      end
    end

    context 'given existing *.js entry name with an option' do
      subject { helper.javascript_bundles_with_chunks_tag('application', 'data-turbolinks-track': 'reload') }

      it 'renders tags for chunk assets' do
        is_expected.to eq(
          %(<script src="/packs/vendors~application~bootstrap-c20632e7baf2c81200d3.chunk.js" data-turbolinks-track="reload"></script>\n) +
          %(<script src="/packs/vendors~application-e55f2aae30c07fb6d82a.chunk.js" data-turbolinks-track="reload"></script>\n) +
          %(<script src="/packs/application-k344a6d59eef8632c9d1.js" data-turbolinks-track="reload"></script>),
        )
      end
    end

    context 'with multiple manifests registration and with manifest: option' do
      subject { helper.javascript_bundles_with_chunks_tag('admin-application', manifest: :admin) }

      let(:manifest_admin_path) { File.expand_path('../../support/files/manifest-admin.json', __dir__) }
      let(:configuration) do
        Minipack::Configuration.new.tap do |c|
          c.cache = false
          c.add :shop, manifest_path
          c.add :admin, manifest_admin_path
        end
      end

      it 'renders tags for chunk assets' do
        is_expected.to eq(
          %(<script src="/packs/vendors~admin-application-e55f2aae30c07fb6d82a.chunk.js"></script>\n) +
          %(<script src="/packs/admin-application-k344a6d59eef8632c9d1.js"></script>),
        )
      end
    end

    context 'given non-existing *.js entry name' do
      subject do
        -> { helper.javascript_bundles_with_chunks_tag('not_found') }
      end

      it 'raises' do
        is_expected.to raise_error Minipack::Manifest::MissingEntryError
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

    context 'given existing *.css entry name symbol' do
      subject { helper.stylesheet_bundle_tag(:item_group_editor) }

      it 'renders a nice <link> tag' do
        is_expected.to eq '<link rel="stylesheet" media="screen" href="/packs/item_group_editor-5d7c7164b8a0a9d675fad9ab410eaa8d.css" />'
      end
    end

    context 'with multiple manifests registration and with manifest: option' do
      subject { helper.stylesheet_bundle_tag('admin-application', manifest: :admin) }

      let(:manifest_admin_path) { File.expand_path('../../support/files/manifest-admin.json', __dir__) }
      let(:configuration) do
        Minipack::Configuration.new.tap do |c|
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
        is_expected.to raise_error Minipack::Manifest::MissingEntryError
      end
    end
  end

  describe '#stylesheet_bundles_with_chunks_tag' do
    context 'given existing *.css entry name' do
      subject { helper.stylesheet_bundles_with_chunks_tag('hello_stimulus') }

      it 'renders tags for chunk assets' do
        is_expected.to eq(
          %(<link rel="stylesheet" media="screen" href="/packs/1-c20632e7baf2c81200d3.chunk.css" />\n) +
          %(<link rel="stylesheet" media="screen" href="/packs/hello_stimulus-k344a6d59eef8632c9d1.chunk.css" />),
        )
      end
    end

    context 'given existing *.css entry name with an option' do
      subject { helper.stylesheet_bundles_with_chunks_tag('hello_stimulus', media: 'all') }

      it 'renders tags for chunk assets' do
        is_expected.to eq(
          %(<link rel="stylesheet" media="all" href="/packs/1-c20632e7baf2c81200d3.chunk.css" />\n) +
          %(<link rel="stylesheet" media="all" href="/packs/hello_stimulus-k344a6d59eef8632c9d1.chunk.css" />),
        )
      end
    end

    context 'with multiple manifests registration and with manifest: option' do
      subject { helper.stylesheet_bundles_with_chunks_tag('admin-hello_stimulus', manifest: :admin) }

      let(:manifest_admin_path) { File.expand_path('../../support/files/manifest-admin.json', __dir__) }
      let(:configuration) do
        Minipack::Configuration.new.tap do |c|
          c.cache = false
          c.add :shop, manifest_path
          c.add :admin, manifest_admin_path
        end
      end

      it 'renders tags for chunk assets' do
        is_expected.to eq(
          %(<link rel="stylesheet" media="screen" href="/packs/1-c20632e7baf2c81200d3.chunk.css" />\n) +
          %(<link rel="stylesheet" media="screen" href="/packs/admin-hello_stimulus-k344a6d59eef8632c9d1.chunk.css" />),
        )
      end
    end

    context 'given non-existing *.css entry name' do
      subject do
        -> { helper.stylesheet_bundles_with_chunks_tag('not_found') }
      end

      it 'raises' do
        is_expected.to raise_error Minipack::Manifest::MissingEntryError
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
        Minipack::Configuration.new.tap do |c|
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
        is_expected.to raise_error Minipack::Manifest::MissingEntryError
      end
    end

    context 'given without extname' do
      subject do
        -> { helper.image_bundle_tag('not_found') }
      end

      it 'raises' do
        is_expected.to raise_error Minipack::Manifest::MissingEntryError
      end
    end
  end
end
