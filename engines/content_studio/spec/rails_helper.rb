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

  # When the host application boots first (via --require rails_helper in the root .rspec),
  # the engine's ApplicationController inherits host-app auth callbacks and the engine is
  # mounted at a different path. Fix both so request specs work from the project root.
  config.before(:suite) do
    next if defined?(Dummy::Application) && Rails.application.is_a?(Dummy::Application)

    Rails.application.routes.draw do
      mount ContentStudio::Engine => '/content_studio', as: 'content_studio_test'
    end

    ContentStudio::ApplicationController.skip_before_action :authenticate_user!, raise: false
    ContentStudio::ApplicationController.skip_before_action :set_back_link, raise: false
    ContentStudio::ApplicationController.skip_before_action :set_active_nav, raise: false
  end
end
