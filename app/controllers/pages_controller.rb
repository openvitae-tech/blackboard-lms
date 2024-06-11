class PagesController < ApplicationController

  layout "devise"

  # Note: No route added in route definition
  # Can be used for building a landing page in future
  def index
  end

  # No route added for these pages these pages should not be accessed directly
  def unauthorized
    render status: 401
  end
end