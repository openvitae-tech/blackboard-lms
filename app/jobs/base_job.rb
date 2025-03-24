# frozen_string_literal: true

require 'utilities/tracing'
class BaseJob
  include Sidekiq::Job
  include Utilities::Tracing
end
