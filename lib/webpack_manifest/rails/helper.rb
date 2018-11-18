# frozen_string_literal: true

require 'action_view'

module WebpackManifest::Rails::Helper
  # Example:
  #
  #   <%= asset_bundle_path 'calendar.css' %> # => "/assets/web/pack/calendar-1016838bab065ae1e122.css"
  #   <%= asset_bundle_path 'icon/favicon.ico' %> # => "/assets/web/pack/icon/favicon-1016838bab065ae1e122.ico"
  def asset_bundle_path(name, manifest: nil, **options)
    manifest = get_manifest_by_key(manifest)
    asset_path(manifest.lookup!(name.to_s), **options)
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
    stylesheet_link_tag(*sources_from_manifest(names, 'css', key: manifest), **options)
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
    image_tag(manifest.lookup!(name.to_s), **options)
  end

  private

  def sources_from_manifest(names, ext, key: nil)
    manifest = get_manifest_by_key(key)
    names.map { |name| manifest.lookup!(name.to_s + '.' + ext) }
  end

  def get_manifest_by_key(key = nil)
    repository = WebpackManifest::Rails.configuration.manifests
    key.nil? ? repository.default : repository.get(key)
  end
end
