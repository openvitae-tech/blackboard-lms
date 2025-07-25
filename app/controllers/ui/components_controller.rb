# frozen_string_literal: true

class Ui::ComponentsController < Ui::BaseController
  def index
  end

  def app
    @house_keeping_ctx = SearchContext.new(context: SearchContext::COURSE_LISTING, tags: ['Housekeeping'])
    service = Courses::FilterService.new(current_user, @house_keeping_ctx)
    @house_keeping_courses = service.filter.records

    @food_production_ctx = SearchContext.new(context: SearchContext::COURSE_LISTING, tags: ['Food Production'])
    service = Courses::FilterService.new(current_user, @food_production_ctx)
    @food_production_courses = service.filter.records
  end
end