# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: %i[show edit update destroy enroll unenroll proceed publish unpublish]

  # GET /courses or /courses.json
  def index
    if current_user.is_admin?
      @enrolled_courses = current_user.courses
      @other_courses = Course.all - @enrolled_courses
    else
      @enrolled_courses = current_user.courses.published
      @other_courses = Course.published - @enrolled_courses
    end
  end

  # GET /courses/1 or /courses/1.json
  def show
    @course_modules = helpers.modules_in_order(@course)
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit; end

  # POST /courses or /courses.json
  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to course_url(@course), notice: 'Course was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    if @course.update(course_params)
      redirect_to course_url(@course), notice: 'Course was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /courses/1 or /courses/1.json
  def destroy
    @course.destroy!
    redirect_to courses_url, notice: 'Course was successfully destroyed.'
  end

  def enroll
    service = CourseManagementService.instance
    result = service.enroll!(current_user, @course)

    if result == :duplicate
      message = 'Already enrolled in this course'
    elsif result == :ok
      message = 'Successfully enrolled for the course'
    end

    redirect_to course_url(@course), notice: message
  end

  def unenroll
    service = CourseManagementService.instance
    result = service.undo_enroll!(current_user, @course)

    if result == :not_enrolled
      message = 'You are not enrolled in this course'
    elsif result == :ok
      message = 'Success'
    end

    redirect_to course_url(@course), notice: message
  end

  def proceed
    service = CourseManagementService.instance
    enrollment = service.proceed(current_user, @course)
    EVENT_LOGGER.publish_course_started(current_user, @course.id)
    redirect_to course_module_lesson_path(@course, enrollment.current_module_id || @course.first_module.id,
                                          enrollment.current_lesson_id || @course.first_module.first_lesson)
  end

  def search
    service = CourseManagementService.instance
    @keyword = params[:term]
    @search_results = service.search(@keyword)
    render :index
  end

  def publish
    service = CourseManagementService.instance
    result = service.publish!(@course)

    if result == :duplicate
      message = 'Course already published'
    elsif result == :ok
      message = 'Course is now available to everyone'
    end

    redirect_to course_url(@course), notice: message
  end

  def unpublish
    service = CourseManagementService.instance
    result = service.undo_publish!(@course)

    if result == :duplicate
      message = 'Course already published'
    elsif result == :ok
      message = 'Course is now available to everyone'
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
    params.require(:course).permit(:title, :rich_description, :banner)
  end
end
