# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'capistrano_recipes'
  s.version       = '1.3.4'
  s.authors       = ['Fernando Aleman']
  s.email         = ['fernandoaleman@mac.com']
  s.description   = 'Capistrano recipes to make your deployments fast and easy'
  s.summary       = 'Capistrano deployment recipes'
  s.homepage      = 'https://github.com/fernandoaleman/capistrano_recipes'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'capistrano',  '~> 2.12'
  s.add_dependency 'bundler',     '~> 1.3'

  s.add_development_dependency 'rspec', '~> 2.5'
end
