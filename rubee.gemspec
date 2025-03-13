Gem::Specification.new do |spec|
  spec.name          = "RuBee"
  spec.version       = "1.1.0"
  spec.authors       = ["Oleg Saltykov"]
  spec.email         = ["oleg.saltykov@gmail.com"]
  spec.summary       = "Fast and lightweight Ruby application server designed for minimalism and flexibility"
  spec.description   = "Application web server written on Ruby"
  spec.homepage      = "https://github.com/nucleom42/rubee"
  spec.license       = "MIT"

  # Define the Ruby version requirement
  spec.required_ruby_version = ">= 3.0.0"

  # Specify which files to include
  spec.files         = Dir["lib/**/*", "README.md", "LICENSE", "bin/*"]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  # Require the main file
  spec.require_paths = ["lib"]
end

