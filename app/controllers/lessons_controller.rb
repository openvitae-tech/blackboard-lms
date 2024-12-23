# frozen_string_literal: true

class LessonsController < ApplicationController
  include LessonsHelper

  before_action :set_course
  before_action :set_course_module
  before_action :set_lesson, only: %i[show edit update destroy complete moveup movedown replay]
  before_action :set_local_content, only: :show

  # GET /lessons or /lessons.json # GET /lessons/1 or /lessons/1.json
  def show
    authorize @lesson
    @enrollment = current_user.get_enrollment_for(@course) if current_user.enrolled_for_course?(@course)

    if @enrollment.present?
      EVENT_LOGGER.publish_lesson_viewed(current_user, @course.id, @lesson.id)
    end

    @course_modules = helpers.modules_in_order(@course)
    @video_iframe = get_video_iframe(@local_content)
  end

  # GET /lessons/new
  def new
    authorize Lesson
    @lesson = @course_module.lessons.new
  end

  # GET /lessons/1/edit
  def edit
    authorize @lesson
  end

  # POST /lessons or /lessons.json
  def create
    authorize Lesson
    service = Lessons::CreateService.instance

    begin
      @lesson = service.create_lesson!(lesson_params, @course_module)
      respond_to do |format|
        format.html do
          redirect_to course_module_lesson_url(@course, @course_module, @lesson),
                      notice: 'Lesson was successfully created.'
        end
        format.json { render :show, status: :created, location: @lesson }
      end
    rescue ActiveRecord::RecordInvalid => exception
      @lesson = exception.record
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lessons/1 or /lessons/1.json
  def update
    authorize @lesson
    service = Lessons::UpdateService.instance

    begin
      service.update_lesson!(@lesson, lesson_params)
      respond_to do |format|
        format.html do
          redirect_to course_module_lesson_path(@course, @course_module, @lesson),
                      notice: 'Lesson was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @lesson }
      end
    rescue ActiveRecord::RecordInvalid => exception
      @lesson = exception.record
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lessons/1 or /lessons/1.json
  def destroy
    authorize @lesson
    service = CourseManagementService.instance
    @lesson.destroy!
    service.update_lesson_ordering!(@course_module, @lesson, :destroy)

    respond_to do |format|
      format.html do
        redirect_to course_module_path(@course, @course_module), notice: 'Lesson was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  def complete
    authorize @lesson
    service = CourseManagementService.instance
    time_spent_in_seconds = (params[:time_spent] || 0).to_i
    enrollment = current_user.get_enrollment_for(@course)

    service.set_progress!(current_user, enrollment, @course_module, @lesson, time_spent_in_seconds)

    if enrollment.module_completed?(@course_module.id) && @course_module.has_quiz? && !enrollment.quiz_completed_for?(@course_module)
      redirect_to course_module_quiz_path(@course, @course_module, @course_module.first_quiz)
      return
    end

    next_path = enrollment.course_completed? ? course_path(@course) : helpers.next_lesson_path(@course, @course_module, @lesson)

    next_path = course_path(@course) if next_path.blank?

    redirect_to next_path
  end

  def moveup
    authorize @lesson
    service = CourseManagementService.instance
    service.update_lesson_ordering!(@course_module, @lesson, :up)

    respond_to do |format|
      format.html { redirect_to course_module_path(@course, @course_module) }
      format.json { head :no_content }
    end
  end

  def movedown
    authorize @lesson
    service = CourseManagementService.instance
    service.update_lesson_ordering!(@course_module, @lesson, :down)

    respond_to do |format|
      format.html { redirect_to course_module_path(@course, @course_module) }
      format.json { head :no_content }
    end
  end

  def replay
    authorize @lesson
    service = CourseManagementService.instance
    enrollment = current_user.get_enrollment_for(@course)
    service.replay!(enrollment, @lesson)
    redirect_to course_module_lesson_url(@course, @course_module, @lesson)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.includes(course_modules: { lessons: :local_contents }).find(params[:course_id])
  end

  def set_course_module
    @course_module = @course.course_modules.find(params[:module_id])
  end

  def set_lesson
    @lesson = @course_module.lessons.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:title,
                                   :rich_description,
                                   :pdf_url,
                                   :lesson_type,
                                   :video_streaming_source,
                                   :course_module_id,
                                   :duration,
                                   local_contents_attributes: %i[id blob_id lang _destroy])
  end

  def set_local_content
    @local_content = if params[:lang].blank?
                default_local_content
             else
               @lesson.local_contents.find_by!(lang: params[:lang])
             end
  end

  def default_local_content
    default_language = @lesson.local_contents.find_by(lang: LocalContent::DEFAULT_LANGUAGE)
    default_language.present? ? default_language : @lesson.local_contents.first
  end
end
