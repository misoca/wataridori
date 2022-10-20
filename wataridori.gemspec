# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wataridori/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = 'wataridori'
  spec.version       = Wataridori::VERSION
  spec.authors       = ['kokuyouwind']
  spec.email         = ['kokuyouwind@gmail.com']

  spec.summary       = 'esa.io team migration tool'
  spec.description   = 'esa.io team migration tool'
  spec.homepage      = 'https://github.com/standfirm/wataridori'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0.0'
  spec.add_development_dependency 'bundler', '~> 2.2.3'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rb-readline'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_dependency 'esa', '~> 1.13.1'
  spec.add_dependency 'hashie', '~> 3.6.0'
  spec.add_dependency 'nokogiri', '>= 1.10.4', '< 1.14.0'
  spec.add_dependency 'retriable', '~> 3.1.1'
end
