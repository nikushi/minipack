
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "webpack_manifest/version"

Gem::Specification.new do |spec|
  spec.name          = "webpack_manifest"
  spec.version       = WebpackManifest::VERSION
  spec.authors       = ["Nobuhiro Nikushi"]
  spec.email         = ["deneb.ge@gmail.com"]

  spec.summary       = "WebpackManifest is a gem that integrates Rails with npm's webpack-manifest-plugin without webpacker."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/nikushi/webpack_manifest"
  spec.license       = "MIT"
  spec.files         = Dir['lib/**/*.rb'] + %w[
    CHANGELOG.md
    LICENSE.txt
    README.md
    Rakefile
    webpack_manifest.gemspec
  ]
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'actionview'
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
