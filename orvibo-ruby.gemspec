# coding: utf-8
require 'date'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "orvibo-ruby"
  spec.version       = "0.0.1"
  spec.authors       = ["Robert Saenz"]
  spec.email         = ["robertsaenz@gmail.com"]
  spec.date          = Date.today
  spec.summary       = 'Ruby library to interface with Orvibo sockets'
  spec.description   = "A simple library to interface with Orvibo sockets"
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.2.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
