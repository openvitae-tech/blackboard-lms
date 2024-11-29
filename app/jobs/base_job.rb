require 'utilities/tracing'
class BaseJob
  include Sidekiq::Job
  include Utilities::Tracing
end
