# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service_contract/generator/version'

Gem::Specification.new do |spec|
  spec.name          = "service_contract-generator"
  spec.version       = ServiceContract::Generator::VERSION
  spec.authors       = ["Jeff Ching"]
  spec.email         = ["jching@avvo.com"]
  spec.summary       = %q{Generates service contracts}
  spec.description   = %q{Binary to help generate service contracts}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "activesupport"
  spec.add_dependency "bundler"

  spec.add_development_dependency "rake", "~> 10.0"
end
