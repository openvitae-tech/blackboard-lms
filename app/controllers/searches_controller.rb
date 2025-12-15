# frozen_string_literal: true
class SearchesController < ApplicationController
  include SearchContextHelper

  def index
    @courses = load_courses.page(params[:page]).per(Course::PER_PAGE_LIMIT)
  end

  def load_more
    @courses = load_courses.page(params[:page]).per(Course::PER_PAGE_LIMIT)
  end


  def list
    @courses = load_courses.page(params[:page]).per(4)
    @target_id = request.headers['X-Target-Id']
  end

  private

  def load_courses
    @search_context = build_search_context
    service = Courses::FilterService.new(current_user, @search_context)
    service.filter.records.includes(:banner_attachment, :tags)
  end
end
