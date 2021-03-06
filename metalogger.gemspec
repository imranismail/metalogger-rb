require_relative 'lib/metalogger/version'

Gem::Specification.new do |spec|
  spec.name          = "metalogger"
  spec.version       = Metalogger::VERSION
  spec.authors       = ["Imran Ismail"]
  spec.email         = ["imran.codely@gmail.com"]

  spec.summary       = %q{a readable and parseable logger}
  spec.description   = %q{a logger that provides a way to incrementally add metadata while staying readable and parseable}
  spec.homepage      = "https://github.com/imranismail/metalogger-rb"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/imranismail/metalogger-rb"
  spec.metadata["changelog_uri"] = "https://github.com/imranismail/metalogger-rb"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
