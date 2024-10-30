# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: %i[show edit update destroy enroll unenroll proceed publish unpublish]

  # GET /courses or /courses.json
  def index
    authorize :course

    if current_user.is_admin?
      @available_courses = Course.all
    else
      @enrolled_courses = current_user.courses.published
      @available_courses = Course.published - @enrolled_courses
    end
  end

  # GET /courses/1 or /courses/1.json
  def show
    authorize @course
    @course_modules = helpers.modules_in_order(@course)
  end

  # GET /courses/new
  def new
    authorize :course
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
    authorize @course
  end

  # POST /courses or /courses.json
  def create
    authorize :course
    @course = Course.new(course_params)

    if @course.save
      redirect_to course_url(@course), notice: I18n.t('course.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    authorize @course
    if @course.update(course_params)
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
    EVENT_LOGGER.publish_course_started(current_user, @course.id)
    redirect_to course_module_lesson_path(@course, enrollment.current_module_id || @course.first_module.id,
                                          enrollment.current_lesson_id || @course.first_module.first_lesson)
  end

  def search
    authorize :course
    service = CourseManagementService.instance
    @keyword = params[:term]
    @search_results = service.search(current_user, @keyword)
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
    params.require(:course).permit(:title, :description, :banner)
  end
end
