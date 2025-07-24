# frozen_string_literal: true

class Ui::ComponentsController < Ui::BaseController
  def index
  end

  def app
    @courses = Course.includes([:tags, :banner_attachment]).take(4)
  end
end