# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
# Guard against double-initialization when the host application has already
# booted (e.g. when running specs from the project root via --require rails_helper).
Rails.application.initialize! unless Rails.application.initialized?
