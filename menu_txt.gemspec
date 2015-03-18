# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'menu_txt/version'

Gem::Specification.new do |spec|
  spec.name          = "menu_txt"
  spec.version       = MenuTxt::VERSION
  spec.authors       = ["Maxim Chernyak"]
  spec.email         = ["max@bitsonnet.com"]

  spec.summary       = 'Build url menu trees in plain text with simple syntax.'
  spec.homepage      = "https://github.com/maxim/menu_txt"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry"
end
