Gem::Specification.new do |spec|
  spec.name          = 'ru.Bee'
  spec.version       = '2.6.5'
  spec.authors       = ['Oleg Saltykov']
  spec.email         = ['oleg.saltykov@gmail.com']
  spec.summary       = 'Fast and lightweight Ruby application server designed for minimalism and flexibility'
  spec.description   = 'Application web server written on Ruby'
  spec.homepage      = 'https://github.com/nucleom42/rubee'
  spec.license       = 'MIT'

  # Define the Ruby version requirement
  spec.required_ruby_version = '>= 3.4.1'

  # Specify which files to include
  spec.files         = Dir['lib/**/*', 'README.md', 'LICENSE', 'bin/*']
  spec.bindir        = 'bin'
  spec.executables   = ['rubee']
  spec.require_paths = ['lib']
end
