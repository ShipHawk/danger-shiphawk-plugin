# frozen_string_literal: true

require './lib/version'

Gem::Specification.new do |spec|
  spec.name                  = 'danger-shiphawk-plugin'
  spec.version               = Danger::ShipHawkPlugin::VERSION
  spec.summary               = 'A Danger plugin for running Ruby files through Rubocop.'
  spec.description           = 'A Danger plugin for running Ruby files through Rubocop.'
  spec.authors               = 'ShipHawk Team'
  spec.email                 = 'dev@shiphawk.com'
  spec.files                 = Dir['README.md', 'LICENSE', 'lib/**/*']
  spec.require_paths         = ['lib']
  spec.homepage              = 'https://git.shiphawk.com/shiphawk/danger-shiphawk-plugin'
  spec.license               = 'MIT'
  spec.required_ruby_version = '>= 2.2.3'

  spec.add_dependency 'danger'
  spec.add_dependency 'rubocop'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
end
