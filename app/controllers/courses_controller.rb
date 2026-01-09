# frozen_string_literal: true

class CoursesController < ApplicationController
  include CourseAssociationsPreloader

  before_action :set_course, only: %i[show edit update destroy enroll unenroll proceed publish unpublish]
  before_action :set_tags, only: %i[new create edit update]

  include SearchContextHelper

  # GET /courses or /courses.json
  def index
    authorize :course
    @search_context = build_search_context(context: :course_listing)

    result = Courses::FilterAdapter.instance.filter_courses(current_user, params[:tags], params[:term], params[:type])

    @available_courses = result[:available_courses]
    @available_courses_count = result[:available_courses_count]
    if !current_user.is_admin?
      @enrolled_courses = result[:enrolled_courses]
      @enrolled_courses_count = result[:enrolled_courses_count]
    end
    @tags = Tag.load_tags
    @type = permitted_type(params[:type])
    apply_pagination
    preload_course_associations
  end

  # GET /courses/1 or /courses/1.json
  def show
    authorize @course
    @course_modules = helpers.modules_in_order(@course)
    @enrollment = current_user.get_enrollment_for(@course)

    if @enrollment.present?
      EVENT_LOGGER.publish_course_viewed(current_user, @course.id)
    end
  end

  # GET /courses/new
  def new
    authorize :course
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
    authorize @course
    @category = @course.tags.category.first
    @level = @course.tags.level.first
  end

  # POST /courses or /courses.json
  def create
    authorize :course
    @course = Course.new(updated_params)

    if @course.save
      render turbo_stream: turbo_stream.redirect_to(course_url(@course)), notice: I18n.t('course.created') 
    else
       render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    authorize @course
    if @course.update(updated_params)
      render turbo_stream: turbo_stream.redirect_to(course_url(@course)), notice: I18n.t('course.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /courses/1 or /courses/1.json
  def destroy
    authorize @course
    @course.destroy!
    redirect_to courses_url, notice: I18n.t('course.deleted')
  end

  def enroll
    authorize @course

    service = CourseManagementService.instance
    result = service.enroll!(current_user, @course)

    if result == :duplicate
      message = I18n.t('course.duplicate_enrolled')
    elsif result == :ok
      message = I18n.t('course.enrolled')
    end

    redirect_to course_url(@course), notice: message
  end

  def unenroll
    authorize @course

    service = CourseManagementService.instance
    result = service.undo_enroll!(current_user, @course)

    if result == :not_enrolled
      message = I18n.t('course.not_enrolled')
    elsif result == :ok
      message = I18n.t('course.unenrolled')
    end

    redirect_to course_url(@course), notice: message
  end

  def proceed
    authorize @course

    service = CourseManagementService.instance
    enrollment = service.proceed(current_user, @course)
    if enrollment.course_started_at.blank?
      EVENT_LOGGER.publish_course_started(current_user, @course.id)
      enrollment.touch(:course_started_at)
    end

    redirect_to course_module_lesson_path(@course, enrollment.current_module_id || @course.first_module.id,
                                          enrollment.current_lesson_id || @course.first_module.first_lesson)
  end

  def publish
    authorize @course

    service = CourseManagementService.instance
    result = service.publish!(@course)

    if result == :duplicate
      message = I18n.t('course.duplicate_publish')
    elsif result == :ok
      message = I18n.t('course.published')
    end

    redirect_to course_url(@course), notice: message
  end

  def unpublish
    authorize @course

    service = CourseManagementService.instance
    result = service.undo_publish!(@course)

    if result == :duplicate
      message = I18n.t('course.duplicate_unpublish')
    elsif result == :ok
      message = I18n.t('course.unpublished')
    end

    redirect_to course_url(@course), notice: message
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def course_params
    params.require(:course).permit(:title, :description, :banner, :category_id, :level_id, :visibility)
  end

  def filter_params
    params.permit(:page)
  end

  def apply_pagination
    if @type.nil?
      @available_courses = @available_courses.page(filter_params[:page])
      @enrolled_courses = @enrolled_courses.page(filter_params[:page]) if !current_user.is_admin?
      return
    end

    if @type == "all"
      @available_courses = @available_courses.page(filter_params[:page])
    else
      @enrolled_courses = @enrolled_courses.page(filter_params[:page]) if !current_user.is_admin?
    end
  end

  def permitted_type(type)
    %w[all enrolled].include?(type) ? type : nil
  end

  def set_tags
    @categories = Tag.category.load_tags
    @levels = Tag.level.load_tags
  end

  def updated_params
    tag_ids = [course_params[:category_id], course_params[:level_id]].compact
    course_params.merge(tag_ids:).except(:category_id, :level_id)
  end
end
