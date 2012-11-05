# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'properties/version'

Gem::Specification.new do |gem|
  gem.name          = "properties"
  gem.version       = Properties::VERSION
  gem.authors       = "Edison"
  gem.email         = "hydra1983@gmail.com"
  gem.description   = "Load java style properties text"
  gem.summary       = "Load java style properties text"
  gem.homepage      = "http://github.com/hydra1983/properties"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end