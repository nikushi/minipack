
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "minipack/version"

Gem::Specification.new do |spec|
  spec.name          = "minipack"
  spec.version       = Minipack::VERSION
  spec.authors       = ["Nobuhiro Nikushi"]
  spec.email         = ["deneb.ge@gmail.com"]

  spec.summary       = "Minipack is a gem for minimalists that integrates Rails and webpack without Webpcker"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/nikushi/minipack"
  spec.license       = "MIT"
  spec.files         = Dir['lib/**/*.rb'] + %w[
    CHANGELOG.md
    LICENSE.txt
    README.md
    Rakefile
    minipack.gemspec
  ]
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'actionview'
  spec.add_dependency "railties", ">= 4.2"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
