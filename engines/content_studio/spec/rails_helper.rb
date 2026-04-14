# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require_relative 'dummy/config/environment'
require 'rspec/rails'

# Content Studio is API-driven with no database. ActiveRecord is loaded as a
# transitive dependency of the `rails` gem but never initialised with a
# connection. Override the fixture hooks that rspec-rails inherits from AR
# so they become no-ops instead of raising ConnectionNotDefined.
module SkipActiveRecordFixtures
  def setup_fixtures(*); end
  def teardown_fixtures(*); end
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.use_transactional_fixtures = false
  config.include SkipActiveRecordFixtures
  config.include ContentStudio::ApplicationHelper, type: :view
end
