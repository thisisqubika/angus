# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'angus/version'

Gem::Specification.new do |spec|
  spec.name          = 'angus'
  spec.version       = Angus::VERSION
  spec.authors       = %w[*sigh*]
  spec.email         = %w[angus@moove-it.com]
  spec.description   = %q{angus}
  spec.summary       = %q{angus}
  spec.homepage      = 'http://www.moove-it.com'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('{lib}/**/*')
  spec.test_files    = Dir.glob('{spec}/**/*').grep(%r{^spec/})
  spec.require_paths = %w[lib]

  spec.add_dependency('picasso-sdoc', '~> 0.0')
  spec.add_dependency('picasso-router', '~> 0.0')

  spec.add_development_dependency('rake')

  # Testing Dependencies
  spec.add_development_dependency('rspec', '~> 2.12')
  spec.add_development_dependency('faker')
  spec.add_development_dependency('simplecov', '~> 0.7')
  spec.add_development_dependency('simplecov-rcov', '~> 0.2')
  spec.add_development_dependency('simplecov-rcov-text', '~> 0.0')
  spec.add_development_dependency('ci_reporter')
end