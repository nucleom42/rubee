Gem::Specification.new do |spec|
  spec.name          = "rubee"
  spec.version       = "1.1.0"
  spec.authors       = ["Oleg Saltykov"]
  spec.email         = ["oleg.saltykov@gmail.com"]
  spec.summary       = "Fast and lightweight Ruby application server designed for minimalism and flexibility"
  spec.description   = "Application web server written on Ruby"
  spec.homepage      = "https://github.com/nucleom42/rubee"
  spec.license       = "MIT"

  # Define the Ruby version requirement
  spec.required_ruby_version = ">= 3.2.1"

  # Runtime dependencies
  spec.add_dependency "bundler", "~> 2.1", ">= 2.1.4"
  # spec.add_dependency "rack", "~> 2.2", ">= 2.2.3"
  # spec.add_dependency "rackup", "~> 2.1", ">= 2.2.3"
  # spec.add_dependency "sequel", "~> 5.51", ">= 5.51.0"
  # spec.add_dependency "sqlite3", "~> 1.4", ">= 1.4.2"
  # spec.add_dependency "puma", "~> 5.6", ">= 5.6.4"

  # Development dependencies
  # spec.add_development_dependency "pry", "~> 0.13", ">= 0.13.1"
  # spec.add_development_dependency "rubocop", "~> 1.7", ">= 1.7.0"
  # spec.add_development_dependency "pry-byebug", "~> 3.9", ">= 3.9.0"
  # spec.add_development_dependency "minitest", "~> 5.15", ">= 5.15.0"

  # Specify which files to include
  spec.files         = Dir["lib/**/*", "README.md", "LICENSE", "bin/*"]
  spec.bindir        = "bin"
  spec.executables   = ["rubee"]
  spec.require_paths = ["lib"]
end

