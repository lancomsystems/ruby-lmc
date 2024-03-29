# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lmc/version'

Gem::Specification.new do |spec|
  spec.name          = 'lmc'
  spec.version       = LMC::VERSION
  spec.authors       = ['erpel']
  spec.email         = ['philipp@copythat.de']

  spec.required_ruby_version = '~> 2.0'
  spec.summary       = %q{Library for interacting with LMC cloud instances}
  spec.license       = 'BSD-3-Clause'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'minitest-reporters', '~> 1'
  spec.add_development_dependency 'pry-nav', '~> 0.2.4'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '~> 1.14'
  spec.add_development_dependency 'simplecov', '~> 0.15'

  spec.add_runtime_dependency 'json', '~> 2.3'
  spec.add_runtime_dependency 'recursive-open-struct', '~> 1.1'
  spec.add_runtime_dependency 'rest-client', '~> 2.0'
end

