class LessonsController < ApplicationController
  before_action :set_course, only: %i[ new create show edit update destroy complete]
  before_action :set_course_module, only: %i[ new create show edit update destroy complete]
  before_action :set_lesson, only: %i[ show edit update destroy complete]

  # GET /lessons or /lessons.json # GET /lessons/1 or /lessons/1.json
  def show
    @enrollment = current_user.get_enrollment_for(@course) if current_user.enrolled_for_course?(@course)
    @course_modules = helpers.modules_in_order(@course)
  end

  # GET /lessons/new
  def new
    @lesson = @course_module.lessons.new
  end

  # GET /lessons/1/edit
  def edit
  end

  # POST /lessons or /lessons.json
  def create
    @lesson = @course_module.lessons.new(lesson_params)
    service = CourseManagementService.instance
    service.set_sequence_number_for_lesson(@course_module, @lesson)
    service.update_lesson_ordering!(@course_module, @lesson, :create)

    respond_to do |format|
      if @lesson.save
        format.html { redirect_to course_module_lesson_url(@course, @course_module, @lesson), notice: "Lesson was successfully created." }
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lessons/1 or /lessons/1.json
  def update
    respond_to do |format|
      if @lesson.update(lesson_params)
        format.html { redirect_to course_module_lesson_path(@course, @course_module, @lesson), notice: "Lesson was successfully updated." }
        format.json { render :show, status: :ok, location: @lesson }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lessons/1 or /lessons/1.json
  def destroy
    service = CourseManagementService.instance
    @lesson.destroy!
    service.update_lesson_ordering!(@course_module, @lesson, :destroy)

    respond_to do |format|
      format.html { redirect_to course_module_path(@course, @course_module), notice: "Lesson was successfully destroyed." }
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
      params.require(:lesson).permit(:title, :description, :video_url, :pdf_url, :lesson_type, :video_streaming_source, :course_module_id, local_contents_attributes: [:lang, :video_url, :_destroy, :id])
    end
end
