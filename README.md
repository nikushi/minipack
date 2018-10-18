# WebpackManifest

WebpackManifest is a gem that integrates Rails with npm's [webpack-manifest-plugin](https://www.npmjs.com/package/webpack-manifest-plugin) without [webpacker](https://github.com/rails/webpacker).

## Features

* Rails view helpers to access assets which are built by webpack according a manifest file.
* Multiple manifest files support

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'webpack_manifest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webpack_manifest

## Usage

### Rails view helpers

#### `asset_bundle_path`

This is a wrapper of [asset_path](https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html#method-i-asset_path). You can set any options of `asset_path`.

Given entry point name is resolved according to definition of manifest.

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

Given entry point name is resolved according to definition of manifest.

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

Given entry point name is resolved according to definition of manifest.

```ruby
image_bundle_tag 'icon.png'
  # => <img src="/assets/pack/icon-1016838bab065ae1e314.png" />

image_bundle_tag "icon.png", size: "16x10", alt: "Edit Entry"
  # => <img src="/assets/pack/icon-1016838bab065ae1e314.png" width="16"
        height="10" alt="Edit Entry" />
```

### Configuration

After installed, configure your Rails app by adding a new file `config/initializers/webpack_manifest.rb` as below.

```rb
WebpackManifest::Rails.configuration do |c|
  # By default c.cache is `false`, which means application always parses given
  # manifest json. Disableing cache is useful in development.
  # Set `true` if you would like to cache manifest in memory, for example in production.
  c.cache = !Rails.env.development?

  # Register a path to a manifest file here.
  c.manifest = Rails.root.join('public', 'assets', 'manifest.json')
end
```

### Multiple manifest files support

This is optional. You can register multiple manifest files for the view helpers. This feature must be useful if your Rails project have several sites, then asset bundling process is separated.

For example, your project serve for two sites, `shop` and `admin` from each separated manifest file. You can register each as below.

```rb
# In config/initializers/webpack_manifest.rb

WebpackManifest::Rails.configuration do |c|
  c.cache = !Rails.env.development?

  # If you have manifest files more than one, register them by `c.add` instead
  # of `c.manifest=`. Note that the first registered one(e.g. `shop` in this
  # example) is recognized as a default manifest.
  c.add :shop,  Rails.root.join('public', 'assets', 'manifest-shop.json')
  c.add :admin, Rails.root.join('public', 'assets', 'manifest-admin.json')
end
```

Then you can resolve paths with view helpers by passing `manifest:` option.

```
# This resolves a path by shop's manifest json.
javascript_bundle_tag('item_group_editor', manifest: :shop)

# This resolves a path by admin's manifest json.
asset_bundle_tag('favicon.ico', manifest: :admin)

# This resolves a path by shop's manifest json implicitly because the first one is marked as a default.
javascript_bundle_tag('item_group_editor')
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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/webpack_manifest.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
