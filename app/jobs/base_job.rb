require 'utilities/tracing'
class BaseJob
  include Sidekiq::Job
  include Tracing
end
