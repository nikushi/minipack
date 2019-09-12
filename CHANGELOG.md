# 0.3.3 / YYYY-MM-DD (not released yet)

## Enhancements:

* Support manifest files that have integrity hashes in them (#24) by @HellRok

## Breaking changes(internal apis only)

* Return value of `Minipack::Manifest#lookup!` and `Minipack::Manifest#find`, now changed from String to `Minipack::Manifest::Entry`.

# 0.3.2 / 2019-07-22

## Enhancements:

* Add ability to instruct minipack if CSS will be in the manifest (#22) by @jmortlock

# 0.3.1 / 2019-06-06

## Bug fixes

* Fix bug that Configuration#manifests returns manifest object with nil path (#21)

# 0.3.0 / 2019-06-01

The project was renamed to Minipack from WebpackManifest since v0.3.0. Please refer to [the migration guide](docs/migrate_from_webpack_manifest.md') from WebpackManifest.

## Breaking changes

* Rename the project as Minipack.

## Enhancements:

* pre-build in test (#11)
* Enable to set default value through config_attr (#16)

# 0.2.4 / 2019-03-25

## Enhancements:

* Added `javascript_bundles_with_chunks_tag` and `stylesheet_bundles_with_chunks_tag` helpers, which creates html tags for a pack and all the dependent chunks, when using splitChunks. (#7)

# 0.2.3 / 2018-11-18

* Support passing symbols to helper methods (#5) by @jmortlock

# 0.2.2 / 2018-11-05

## Enhancements

* Support reading manifest.json from an uri (#4)

# 0.2.1 / 2018-10-18

* Improve exceptional case handling

# 0.2.0 / 2018-10-18

## Enhancements

* Multiple manifest files support

## Breaking changes

* Changed internal and public APIs

# 0.1.0 / 2018-10-17

Initial release
