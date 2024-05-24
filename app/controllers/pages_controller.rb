class PagesController < ApplicationController

  layout "devise"

  def index
  end

  # No route added for these pages these pages should not be accessed directly
  def unauthorized
    render status: 401
  end
end