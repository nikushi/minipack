# WebpackManifest

WebpackManifest is a gem that integrate ruby with npm's [webpack-manifest-plugin](https://www.npmjs.com/package/webpack-manifest-plugin).

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

* `#asset_bundle_path`
* `#javascript_bundle_tag`
* `#stylesheet_bundle_tag`
* `#image_bundle_tag`

### Configuration

```rb
# In config/initializers/webpack_manifest.rb

WebpackManifest::Rails.configuration do |c|
  c.manifest = Rails.root.join('public', 'assets', 'manifest.json')
end
```

### Multiple manifest files support

This is optional. You can register multiple manifest files for the view helpers. This feature must be useful if your Rails project have several sites, then asset bundling process is separated.

```rb
# In config/initializers/webpack_manifest.rb

# For example, your project serve two sites, `shop` and `admin` from each manifest file.
# You can register each file as below. Note that the first one would be regstered as a default manifest.
WebpackManifest::Rails.configuration do |c|
  c.add :shop,  Rails.root.join('public', 'assets', 'manifest-shop.json')
  c.add :admin, Rails.root.join('public', 'assets', 'manifest-admin.json')
end
```

Then you can use view helpers with `manifest:` option.

```
# This resolves a path by shop's manifest json.
javascript_bundle_tag('item_group_editor', manifest: :shop)

# This resolves a path by admin's manifest json.
asset_bundle_tag('favicon.ico', manifest: :admin)

# This resolves a path by shop's manifest json implicitly because the first one is marked as a default.
javascript_bundle_tag('item_group_editor')
```

## Roadmap

* [x] Implement manifest class
* [x] Implement Rails view helpers
* [ ] Configuration generator for Rails initializers
* [ ] Multiple manifest files support
* [ ] Write document more

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/webpack_manifest.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
