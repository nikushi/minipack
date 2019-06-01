# How to migrate from WebpackManifest

To migrate from WebpackManifest `<= v0.2.4` to Minipack `v0.3.0` or above, follow these steps:

1. Update Gemfile. Remove the line for webpack_manifest, then add a new line for minipack.

```diff
# Gemfile
-gem 'webpack_manifest'
+gem 'minipack'
```

2. Run bundle install. Gemfile.lock will be automatically updated.

3. Rename and modify the configuration file.

This step is strongly recommended, although it can be skipped because Minipack v0.3.0 still works with old configuration made before. Old configuration support will be removed in v0.4.0.

First, rename `config/initializers/webpack_manifest.rb` as `config/initializers/minipack.rb`. Then, modify the class name at the top of the file as follows:

```diff
-WebpackManifest::Rails.configuration do |c|
+Minipack.configuration do |c|
```

4. Make sure if your app could work

Make sure your app works normally, and also check out that the all request specs would pass.

That's it! Thank you.
