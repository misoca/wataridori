
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wataridori/version"

Gem::Specification.new do |spec|
  spec.name          = "wataridori"
  spec.version       = Wataridori::VERSION
  spec.authors       = ["kokuyouwind"]
  spec.email         = ["kokuyouwind@gmail.com"]

  spec.summary       = %q{esa.io team migration tool}
  spec.description   = %q{esa.io team migration tool}
  spec.homepage      = "https://github.com/standfirm/wataridori"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_dependency "esa", "~> 1.13.1"
end
