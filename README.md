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

cache = if Rails.env.development?
          false
        else
          true
        end
manifest = WebpackManifest::Manifest.new(
  Rails.root.join('public', 'assets', 'manifest.json'),
  cache: cache,
)
```


### Multiple manifest support

TBD

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
