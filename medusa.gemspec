# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "medusa"
  spec.version       = "0.0.1"
  spec.authors       = ["Nick Gauthier", "Sean St. Quentin"]
  spec.email         = ["ngauthier@gmail.com", "sean.st.quentin@envato.com"]
  spec.description   = %q{Spread your tests over multiple machines to test your code faster.}
  spec.summary       = %q{Distributed testing toolkit}
  spec.homepage      = "http://github.com/ngauthier/medusa"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "shoulda", "~> 2.10.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "pry"
end
