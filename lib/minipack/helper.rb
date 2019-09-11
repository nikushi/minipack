# frozen_string_literal: true

require 'action_view'

module Minipack::Helper
  # Example:
  #
  #   <%= asset_bundle_path 'calendar.css' %> # => "/assets/web/pack/calendar-1016838bab065ae1e122.css"
  #   <%= asset_bundle_path 'icon/favicon.ico' %> # => "/assets/web/pack/icon/favicon-1016838bab065ae1e122.ico"
  def asset_bundle_path(name, manifest: nil, **options)
    manifest = get_manifest_by_key(manifest)
    asset_path(manifest.lookup!(name.to_s).path, **options)
  end

  # Example:
  #
  #   <%= javascript_bundle_tag 'calendar', 'data-turbolinks-track': 'reload' %> # =>
  #   <script src="/assets/web/pack/calendar-1016838bab065ae1e314.js" data-turbolinks-track="reload"></script>
  #
  #   <%= javascript_bundle_tag 'orders/app'  %> # =>
  #   <script src="/assets/web/pack/orders/app-1016838bab065ae1e314.js"></script>
  def javascript_bundle_tag(*names, manifest: nil, **options)
    javascript_include_tag(*sources_from_manifest(names, 'js', key: manifest), **options)
  end

  # Creates script tags that references the js chunks from entrypoints when using split chunks API.
  # See: https://webpack.js.org/plugins/split-chunks-plugin/
  # Example:
  #
  #   <%= javascript_bundles_with_chunks_tag 'calendar', 'map', 'data-turbolinks-track': 'reload' %> # =>
  #   <script src="/packs/vendor-16838bab065ae1e314.chunk.js" data-turbolinks-track="reload"></script>
  #   <script src="/packs/calendar~runtime-16838bab065ae1e314.chunk.js" data-turbolinks-track="reload"></script>
  #   <script src="/packs/calendar-1016838bab065ae1e314.chunk.js" data-turbolinks-track="reload"></script>
  #   <script src="/packs/map~runtime-16838bab065ae1e314.chunk.js" data-turbolinks-track="reload"></script>
  #   <script src="/packs/map-16838bab065ae1e314.chunk.js" data-turbolinks-track="reload"></script>
  # DO:
  # <%= javascript_bundles_with_chunks_tag 'calendar', 'map' %>
  # DON'T:
  # <%= javascript_bundles_with_chunks_tag 'calendar' %>
  # <%= javascript_bundles_with_chunks_tag 'map' %>
  def javascript_bundles_with_chunks_tag(*names, manifest: nil, **options)
    javascript_include_tag(*sources_from_manifest_entrypoints(names, 'js', key: manifest), **options)
  end

  # Examples:
  #
  #   <%= stylesheet_bundle_tag 'calendar', 'data-turbolinks-track': 'reload' %> # =>
  #   <link rel="stylesheet" media="screen"
  #    href="/assets/web/pack/calendar-1016838bab065ae1e122.css" data-turbolinks-track="reload" />
  #
  #   <%= stylesheet_bundle_tag 'orders/style' %> # =>
  #   <link rel="stylesheet" media="screen"
  #    href="/assets/web/pack/orders/style-1016838bab065ae1e122.css" />
  def stylesheet_bundle_tag(*names, manifest: nil, **options)
    if Minipack.configuration.extract_css?
      stylesheet_link_tag(*sources_from_manifest(names, 'css', key: manifest), **options)
    end
  end

  # Creates link tags that references the css chunks from entrypoints when using split chunks API.
  # See: https://webpack.js.org/plugins/split-chunks-plugin/
  # Example:
  #
  #   <%= stylesheet_bundles_with_chunks_tag 'calendar', 'map' %> # =>
  #   <link rel="stylesheet" media="screen" href="/packs/3-8c7ce31a.chunk.css" />
  #   <link rel="stylesheet" media="screen" href="/packs/calendar-8c7ce31a.chunk.css" />
  #   <link rel="stylesheet" media="screen" href="/packs/map-8c7ce31a.chunk.css" />
  # DO:
  # <%= stylesheet_bundles_with_chunks_tag 'calendar', 'map' %>
  # DON'T:
  # <%= stylesheet_bundles_with_chunks_tag 'calendar' %>
  # <%= stylesheet_bundles_with_chunks_tag 'map' %>
  def stylesheet_bundles_with_chunks_tag(*names, manifest: nil, **options)
    if Minipack.configuration.extract_css?
      stylesheet_link_tag(*sources_from_manifest_entrypoints(names, 'css', key: manifest), **options)
    end
  end

  # Examples:
  #
  #   <%= image_bundle_tag 'icon.png'
  #   <img src="/assets/pack/icon-1016838bab065ae1e314.png" />
  #
  #   <%= image_bundle_tag "icon.png", size: "16x10", alt: "Edit Entry"
  #   <img src="/assets/pack/icon-1016838bab065ae1e314.png" width="16" height="10" alt="Edit Entry" />
  def image_bundle_tag(name, manifest: nil, **options)
    manifest = get_manifest_by_key(manifest)
    image_tag(manifest.lookup!(name.to_s).path, **options)
  end

  private

  def sources_from_manifest(names, ext, key: nil)
    manifest = get_manifest_by_key(key)
    names.map { |name| manifest.lookup!(name.to_s + '.' + ext).path }
  end

  def sources_from_manifest_entrypoints(names, type, key: nil)
    manifest = get_manifest_by_key(key)
    names.map { |name| manifest.lookup_pack_with_chunks!(name, type: type).entries.map(&:path) }.flatten.uniq
  end

  def get_manifest_by_key(key = nil)
    repository = Minipack.configuration.manifests
    key.nil? ? repository.default : repository.get(key)
  end
end
