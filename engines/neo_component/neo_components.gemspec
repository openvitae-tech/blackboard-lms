# frozen_string_literal: true

require_relative 'lib/neo_components/version'

Gem::Specification.new do |spec|
  spec.name        = 'neo_components'
  spec.version     = NeoComponents::VERSION
  spec.authors     = ['Deepak']
  spec.email       = ['deepakkumarnd@gmail.com']
  spec.homepage    = 'https://rubygems.org/gems/neo_components'
  spec.summary     = 'Reusable UI component library for Rails applications'
  spec.description = 'Provides ViewComponent helpers, ERB partials, Tailwind CSS styles, ' \
                     'SVG icons, and Stimulus controllers.'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.files = Dir[
    'lib/**/*',
    'app/**/*',
    'config/**/*',
    'LICENSE',
    'README.md'
  ]

  spec.require_paths = ['lib']

  spec.add_dependency 'importmap-rails', '~> 2.0'
  spec.add_dependency 'nokogiri', '~> 1.0'
  spec.add_dependency 'rails', '>= 7.0', '< 9'
  spec.add_dependency 'sprockets-rails', '~> 3.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
