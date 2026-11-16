# coding: UTF-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'angus/version'

Gem::Specification.new do |spec|
  spec.name          = 'angus'
  spec.version       = Angus::VERSION
  spec.authors       = ['Pablo Ifran', 'Adrian Gomez', 'Gianfranco Zas', 'Gabriel Fagundez',
                        'Maximo Gomez', 'Guzman Iglesias', 'Martin Cabrera', 'Marcelo Casiraghi', 'Lucas Aragno']
  spec.email         = %w[angus@qubika.com]
  spec.description   = %q{Angus is a simple and powerful framework to build REST APIs using Ruby.}
  spec.summary       = %q{A web services summary}
  spec.homepage      = 'http://thisisqubika.github.io/angus'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.5'

  spec.files         = Dir.glob('{lib}/**/*')
  spec.test_files    = Dir.glob('{spec}/**/*').grep(%r{^spec/})
  spec.require_paths = %w[lib]
  spec.bindir        = 'bin'
  spec.executables   = %w[angus]

  spec.add_dependency('thor')
  spec.add_dependency('angus-sdoc', '~> 0.0', '>= 0.0.7')
  spec.add_dependency('angus-router', '~> 0.0', '>= 0.0.3')

  spec.add_development_dependency('rake')

  # Testing Dependencies
  spec.add_development_dependency('rspec', '~> 3.0')
  spec.add_development_dependency('rspec-its', '~> 1.3', '>= 1.3.1')
  spec.add_development_dependency('faker')
  spec.add_development_dependency('simplecov', '>= 0.22', '< 1')
  spec.add_development_dependency('rack-test', '~> 2.2', '< 3')
  spec.add_dependency('bigdecimal')
end
