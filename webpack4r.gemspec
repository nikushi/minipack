
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "webpack4r/version"

Gem::Specification.new do |spec|
  spec.name          = "webpack4r"
  spec.version       = Webpack4r::VERSION
  spec.authors       = ["Nobuhiro Nikushi"]
  spec.email         = ["deneb.ge@gmail.com"]

  spec.summary       = "Webpack4r is a gem that integrates Rails with npm's webpack-manifest-plugin without webpacker."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/nikushi/webpack4r"
  spec.license       = "MIT"
  spec.files         = Dir['lib/**/*.rb'] + %w[
    CHANGELOG.md
    LICENSE.txt
    README.md
    Rakefile
    webpack4r.gemspec
  ]
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'actionview'
  spec.add_dependency "railties", ">= 4.2"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
