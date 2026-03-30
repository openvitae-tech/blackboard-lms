# frozen_string_literal: true

require_relative 'lib/content_studio/version'

Gem::Specification.new do |spec|
  spec.name                  = 'content_studio'
  spec.version               = ContentStudio::VERSION
  spec.required_ruby_version = '>= 3.3.0'
  spec.authors               = ['dr-r3d']
  spec.email                 = ['abhishek.1984.anand@gmail.com']
  spec.homepage              = 'https://github.com/openvitae-tech/blackboard-lms'
  spec.summary               = 'Portable content creation engine for BlackboardLMS.'
  spec.description           = 'A mountable Rails engine for creating and managing course content.'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/openvitae-tech/blackboard-lms'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails', '>= 8.0.2.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
