# frozen_string_literal: true
class SearchesController < ApplicationController
  include SearchContextHelper

  def index
    @search_context = build_search_context
    service = Courses::FilterService.new(current_user, @search_context)
    @courses = service.filter.records.page(params[:page]).per(Course::PER_PAGE_LIMIT)
  end
end