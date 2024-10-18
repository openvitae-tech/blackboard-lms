# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_course
  before_action :set_course_module
  before_action :set_lesson, only: %i[show edit update destroy complete moveup movedown]

  # GET /lessons or /lessons.json # GET /lessons/1 or /lessons/1.json
  def show
    authorize @lesson
    @enrollment = current_user.get_enrollment_for(@course) if current_user.enrolled_for_course?(@course)
    @course_modules = helpers.modules_in_order(@course)
    @lang = params[:lang]
    video_url = @lesson.video_url_for_lang(@lang)
    @video_iframe = get_video_iframe(video_url)
    Rails.logger.info @video_iframe
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
    @lesson = @course_module.lessons.new(lesson_params)
    service = CourseManagementService.instance

    respond_to do |format|
      if @lesson.save
        service.update_lesson_ordering!(@course_module, @lesson, :create)
        format.html do
          redirect_to course_module_lesson_url(@course, @course_module, @lesson),
                      notice: 'Lesson was successfully created.'
        end
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lessons/1 or /lessons/1.json
  def update
    authorize @lesson
    respond_to do |format|
      if @lesson.update(lesson_params)
        format.html do
          redirect_to course_module_lesson_path(@course, @course_module, @lesson),
                      notice: 'Lesson was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @lesson }
      else
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
    service.complete!(current_user, @course, @course_module, @lesson, time_spent_in_seconds)

    enrollment = current_user.get_enrollment_for(@course)

    if helpers.module_completed?(enrollment, @course_module) && @course_module.has_quiz?
      redirect_to course_module_quiz_path(@course, @course_module, @course_module.first_quiz)
      return
    end

    next_path = helpers.next_lesson_path(@course, @course_module, @lesson)
    next_path = course_path(@course) if next_path.blank? # the course is completed

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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_course_module
    @course_module = @course.course_modules.find(params[:module_id])
  end

  def set_lesson
    @lesson = @course_module.lessons.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def lesson_params
    params.require(:lesson).permit(:title,
                                   :rich_description,
                                   :video_url,
                                   :pdf_url,
                                   :lesson_type,
                                   :video_streaming_source,
                                   :course_module_id,
                                   :duration,
                                   local_contents_attributes: %i[lang video_url _destroy id])
  end

  def get_video_iframe(video_url)
    vimeo_service = VimeoService.instance

    if video_url.present?
      vendor_response = vimeo_service.resolve_video_url(video_url)
      vendor_response['html'] if vendor_response.has_key?('html')
    end
  end
end
