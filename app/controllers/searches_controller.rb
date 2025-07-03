# frozen_string_literal: true
class SearchesController < ApplicationController
  include SearchContextHelper

  def index
    service = Courses::FilterService.instance
    @search_context = build_search_context
    @courses = service.filter(current_user, @search_context).page(params[:page]).per(Course::PER_PAGE_LIMIT)
  end
end