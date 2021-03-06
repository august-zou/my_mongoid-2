# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'my_mongoid/version'

Gem::Specification.new do |spec|
  spec.name          = "my_mongoid"
  spec.version       = MyMongoid::VERSION
  spec.authors       = ["yanmin"]
  spec.email         = ["shaoyan.alpha@gmail.com"]
  spec.summary       = %q{Persistance for MongoDB.}
  spec.description   = %q{MyMongoid is an ORM for MongoDB.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency("moped", ["~> 2.0.beta6"])
  spec.add_dependency("activesupport", ["~> 3.0.0"])
  spec.add_dependency("i18n")
end
