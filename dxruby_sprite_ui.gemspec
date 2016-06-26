# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dxruby_sprite_ui/version'

Gem::Specification.new do |spec|
  spec.name          = "dxruby_sprite_ui"
  spec.version       = DXRuby::SpriteUI::VERSION
  spec.authors       = ["aoitaku"]
  spec.email         = ["aoitaku@gmail.com"]
  spec.summary       = %q{UI Framework for game with DXRuby::Sprite on Quincite UI Framework}
  spec.description   = %q{UI Framework for game with DXRuby::Sprite on Quincite UI Framework}
  spec.homepage      = ""
  spec.license       = "zlib/libpng"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "quincite", "~> 0.1.0"
end
