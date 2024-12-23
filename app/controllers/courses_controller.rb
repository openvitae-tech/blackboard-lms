# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update destroy enroll unenroll proceed publish unpublish]
  before_action :set_tags, only: %i[new create edit update]

  # GET /courses or /courses.json
  def index
    authorize :course

    if current_user.is_admin?
      @available_courses = Course.includes([:banner_attachment]).all.limit(10)
      @available_courses_count = Course.count
    else
      enrolled_course_ids = current_user.courses.pluck(:id)
      @enrolled_courses = current_user.courses.includes([:banner_attachment, :enrollments]).limit(2)
      @available_courses = Course.includes([:banner_attachment]).published.where.not(id: enrolled_course_ids).limit(10)

      @enrolled_courses_count = current_user.courses.includes(:enrollments).size
      @available_courses_count = Course.published.where.not(id: enrolled_course_ids).count
    end
    @type = permitted_type(params[:type])
    apply_pagination if @type.present?
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
      redirect_to course_url(@course), notice: I18n.t('course.created')
    else
       render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    authorize @course
    if @course.update(updated_params)
      redirect_to course_url(@course), notice: I18n.t('course.updated')
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

  def search
    authorize :course
    service = CourseManagementService.instance
    @keyword = params[:term]
    search_query = service.search(current_user, @keyword)
    @search_results = search_query.page(filter_params[:page])
    @search_results_count = search_query.size
    render :index
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
    params.require(:course).permit(:title, :description, :banner, :category_id, :level_id)
  end

  def filter_params
    params.permit(:page)
  end

  def apply_pagination
    @available_courses = @available_courses.page(filter_params[:page])
    @enrolled_courses = @enrolled_courses.page(filter_params[:page]) if !current_user.is_admin?
  end

  def permitted_type(type)
    %w[all enrolled].include?(type) ? type : nil
  end

  def set_tags
    @categories = Tag.category
    @levels = Tag.level
  end

  def updated_params
    tag_ids = [course_params[:category_id], course_params[:level_id]].compact
    course_params.merge(tag_ids:).except(:category_id, :level_id)
  end
end
