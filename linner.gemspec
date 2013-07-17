# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linner/version'

Gem::Specification.new do |spec|
  spec.name          = "linner"
  spec.version       = Linner::VERSION
  spec.authors       = ["Saito"]
  spec.email         = ["saitowu@gmail.com"]
  spec.description   = %q{HTML5 Application Assembler}
  spec.summary       = %q{HTML5 Application Assembler}
  spec.homepage      = "https://github.com/saitowu/linner"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.18"
  spec.add_dependency "tilt", "~> 1.4"
  spec.add_dependency "sass", "~> 3.2"
  spec.add_dependency "listen", "~> 1.2"
  spec.add_dependency "uglifier", "~> 2.1"
  spec.add_dependency "coffee-script", "~> 2.2"
  spec.add_dependency "yui-compressor", "~> 0.9.6"
  spec.add_dependency "terminal-notifier", "~> 1.4"
  spec.add_dependency "stylus", "~> 0.7.2"
  spec.add_dependency "stylus-source", "~> 0.34.1"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "bundler", "~> 1.3"
end
