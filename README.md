# WebpackManifest [![Build Status](https://travis-ci.org/nikushi/webpack_manifest.svg?branch=master)](https://travis-ci.org/nikushi/webpack_manifest) [![Gem Version](https://badge.fury.io/rb/webpack_manifest.svg)](https://badge.fury.io/rb/webpack_manifest)

WebpackManifest is a gem that integrates Rails with npm's [webpack-manifest-plugin](https://www.npmjs.com/package/webpack-manifest-plugin) without [Webpacker](https://github.com/rails/webpacker).

## Features

* Rails view helpers to resolve paths to assets which are built by webpack according to a manifest file.
* Multiple manifest files support
* Pre-compile assets before running tests

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'webpack_manifest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webpack_manifest

## Configuration

After installed, configure your Rails app below as a new file `config/initializers/webpack_manifest.rb`.

```rb
WebpackManifest::Rails.configuration do |c|
  # By default c.cache is set to `false`, which means an application always parses a
  # manifest.json. In development, you should set cache false usually.
  # Instead, setting it `true` which caches the manifest in memory is recommended basically.
  c.cache = !Rails.env.development?

  # Register a path to a manifest file here. Right now you have to specify an absolute path.
  c.manifest = Rails.root.join('public', 'assets', 'manifest.json')

  # The base directory for the frontend system. By default, it will be
  # `Rails.root`.
  # c.base_path = Rails.root
  #
  # Suppose you want to change the root directory for the frontend system such as `frontend`.
  # Note that a base_path can be a relative path from `Rails.root`.
  # c.base_path = 'frontend'

  # When running tests, the lazy compilation is cached until a file is changed
  # under your tracked paths. You can configure which paths are tracked by
  # adding new paths to `watched_paths` array. Each path can be a relative path
  # from the `base_dir`.
  #
  # The value will be as follows by default:
  # c.watched_paths = [
  #   'package.json', 'package-lock.json', 'yarn.lock', 'webpack.config.js',
  #   'webpackfile.js', 'config/webpack.config.js', 'config/webpackfile.js',
  #   'app/javascripts/**/*',
  # ]
  #
  # You can override it.
  # c.watched_paths = ['package.json', 'package-lock.json', 'config/webpack.config.js', 'src/**/*'] 
  #
  # Or you can add files in addition to the defaults:
  # c.watched_paths << 'src/**/*'

  # A full webpack command to build assets'. The command you specify is executed under the `base_dir`.
  # c.compiler_command = 'node_modules/.bin/webpack'
  #
  # You may want to customize it with options:
  # c.compiler_command = 'node_modules/.bin/webpack --config config/webpack.config.js --mode production'
  #
  # You are also able to specify npm run script.
  # c.compiler_command = 'npm run build'

  # A full package installation command. The command is executed under the `base_path`.
  # c.installer_command = 'npm install'
  #
  # If you prefer `yarn`:
  # c.installer_command = 'yarn install'
end
```

## Usage

### Rails view helpers

#### `asset_bundle_path`

This is a wrapper of [asset_path](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html#method-i-asset_path). You can set any options of `asset_path`.

A given entry point name is resolved according to definition of manifest.

```ruby
asset_bundle_path 'calendar.css'
  # => "/assets/web/pack/calendar-1016838bab065ae1e122.css"

asset_bundle_path 'icon/favicon.ico'
  # => "/assets/web/pack/icon/favicon-1016838bab065ae1e122.ico"
```

#### `javascript_bundle_tag`

This is a wrapper of [javascript_include_tag](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag). You can set any options of `javascript_include_tag`.

Given entry point name is resolved according to definition of manifest.

```ruby
javascript_bundle_tag 'calendar', 'data-turbolinks-track': 'reload'
  # => <script src="/assets/web/pack/calendar-1016838bab065ae1e314.js"
  #     data-turbolinks-track="reload"></script>

javascript_bundle_tag 'orders/app'
  # => <script src="/assets/web/pack/orders/app-1016838bab065ae1e314.js"></script>
```

#### `stylesheet_bundle_tag`

This is a wrapper of [stylesheet_link_tag](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag). You can set any options of `stylesheet_link_tag`.

A given entry point name is resolved according to definition of manifest.

```ruby
stylesheet_bundle_tag 'calendar', 'data-turbolinks-track': 'reload'
  # => <link rel="stylesheet" media="screen"
  #     href="/assets/web/pack/calendar-1016838bab065ae1e122.css"
  #     data-turbolinks-track="reload" />

stylesheet_bundle_tag 'orders/style'
  # => <link rel="stylesheet" media="screen"
  #    href="/assets/web/pack/orders/style-1016838bab065ae1e122.css" />
```

#### `image_bundle_tag`

This is a wrapper of [image_tag](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag). You can set any options of `image_tag`.

A given entry point name is resolved according to definition of manifest.

```ruby
image_bundle_tag 'icon.png'
  # => <img src="/assets/pack/icon-1016838bab065ae1e314.png" />

image_bundle_tag "icon.png", size: "16x10", alt: "Edit Entry"
  # => <img src="/assets/pack/icon-1016838bab065ae1e314.png" width="16"
        height="10" alt="Edit Entry" />
```


#### `javascript_bundles_with_chunks_tag` and `stylesheet_bundles_with_chunks_tag`

**Experimental** These are the helpers, which are similar to Webpacker, to support `splitChunks` feature introduced since Webpack 4.

For the full configuration options of splitChunks, see the Webpack's [documentation](https://webpack.js.org/plugins/split-chunks-plugin/).

Then use the `javascript_bundles_with_chunks_tag` and `stylesheet_bundles_with_chunks_tag` helpers to include all
the transpiled packs with the chunks in your view, which creates html tags for all the chunks.

```
<%= javascript_bundles_with_chunks_tag 'calendar', 'map', 'data-turbolinks-track': 'reload' %>

<!-- Creates the following: -->
<script src="/packs/vendor-16838bab065ae1e314.js" data-turbolinks-track="reload"></script>
<script src="/packs/calendar~runtime-16838bab065ae1e314.js" data-turbolinks-track="reload"></script>
<script src="/packs/calendar-1016838bab065ae1e314.js" data-turbolinks-track="reload"></script>
<script src="/packs/map~runtime-16838bab065ae1e314.js" data-turbolinks-track="reload"></script>
<script src="/packs/map-16838bab065ae1e314.js" data-turbolinks-track="reload"></script>
```

**Important:** Pass all your pack names to the helper otherwise you will get duplicated chunks on the page.

```
<%# DO %>
<%= javascript_bundles_with_chunks_tag 'calendar', 'map' %>

<%# DON'T %>
<%= javascript_bundles_with_chunks_tag 'calendar' %>
<%= javascript_bundles_with_chunks_tag 'map' %>
```

**Important:** Also, these helpers do not work with `webpack-manifest-plugin` npm because it has no support to generate a manifest with a set of of chunk entries https://github.com/danethurber/webpack-manifest-plugin/issues/133. Instead, [webpack-assets-manifest](https://github.com/webdeveric/webpack-assets-manifest) npm supports. Please change the plugin for manifest file generation if you wish to enable `splitChunks` feature.

```
const WebpackAssetsManifest = require('webpack-assets-manifest');

module.exports = {
  // ...
  plugins: [
    new WebpackAssetsManifest({
      entrypoints: true, // Please set this as true
    })
  ],
  // ...
}
```

## Advanced Configuration

### Hot Module Replacement in development

Optionally you can integrate the gem with [webpack-dev-server](https://github.com/webpack/webpack-dev-server) to enable live reloading by setting an manifest url served by webpack-dev-server, instead of a local file path. This should be used for development only.

Note that WebpackManifest itself does not launches webpack-dev-server, so it must be started along with Rails server by yourself.

```rb
WebpackManifest::Rails.configuration do |c|
  c.cache = !Rails.env.development?

  c.manifest = if Rails.env.development?
                 'http://localhost:8080/packs/manifest.json'
               else
                 Rails.root.join('public', 'assets', 'manifest.json')
               end
end
```

### Multiple manifest files support

This is optional. You can register multiple manifest files for the view helpers. This feature must be useful if your Rails project serves for several sites, then asset bundling process is isolated every site.

For example, your project serve for two sites, `shop` and `admin` from each individual manifest file. You can register each as

```rb
# In config/initializers/webpack_manifest.rb

WebpackManifest::Rails.configuration do |c|
  c.cache = !Rails.env.development?

  # In order for Raild to handle multiple manifests, you must call `c.add` instead
  # of `c.manifest=`. Note that the first registered one(e.g. `shop` in this
  # example) is recognized as a default manifest.
  c.add :shop do |co|
    co.manifest = Rails.root.join('public', 'assets', 'manifest-shop.json')
    co.base_path = Rails.root.join('frontend/shop')
  end

  c.add :admin do |co|
    co.manifest = Rails.root.join('public', 'assets', 'manifest-admin.json')
    co.base_path = Rails.root.join('frontend/admin')
    # You can customize all configurable parameters per site.
    co.watched_paths << 'javascripts/**/*'
    co.compiler_command = 'yarn install'
  end
end
```

Then you can resolve a path with view helpers by passing `manifest:` option.

```
# This resolves a path by shop's manifest json.
javascript_bundle_tag('item_group_editor', manifest: :shop)

# This resolves a path by admin's manifest json.
asset_bundle_tag('favicon.ico', manifest: :admin)

# This resolves a path by shop's manifest json implicitly because the first one is marked as a default.
javascript_bundle_tag('item_group_editor')
```

## Pre-compiling assets before running tests

The gem can pre-compile assets before runngin tests. To do so, configure the RSpec as follows:

```rb
# spec/rails_helper.rb

require 'webpack_manifest/rails/rspec/compilable'

RSpec.configure do |config|
  config.before :suite do
    WebpackManifest::Rails::RSpec::Compilable.compile
  end
end
```

## TODO

* Provides configuration generator for Rails initializers

## Acknowledgement

Special thanks to [@f_subal](https://twitter.com/f_subal) and his awesome blog [post](https://inside.pixiv.blog/subal/4615)(japanese).

## Alternatives

* [ed-mare/webpack_manifest_plugin](https://github.com/ed-mare/webpack_manifest_plugin)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nikushi/webpack_manifest.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
