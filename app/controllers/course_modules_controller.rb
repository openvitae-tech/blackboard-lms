# frozen_string_literal: true

class CourseModulesController < ApplicationController
  before_action :set_course, only: %i[new create show edit update destroy moveup movedown summary redo_quiz]
  before_action :set_course_module, only: %i[show edit update destroy moveup movedown summary redo_quiz]

  def show
    authorize @course_module
    @lessons = @course_module.lessons_in_order
    @quizzes = helpers.quizzes_in_order(@course_module)
    @enrollment = current_user.get_enrollment_for(@course) if current_user.enrolled_for_course?(@course)
    @quiz_generation_service = Quizzes::GenerationService.new(@course_module)
  end

  # GET /course_modules/new
  def new
    authorize :course_module
    @course_module = @course.course_modules.new
  end

  # GET /course_modules/1/edit
  def edit
    authorize @course_module
  end

  # POST /course_modules or /course_modules.json
  def create
    authorize :course_module
    @course_module = @course.course_modules.new(course_module_params)
    service = Courses::ManagementService.instance

    if @course_module.save
      service.update_module_ordering(@course, @course_module, :create)
      flash[:notice] = I18n.t('course.module_created')

      respond_to do |format|
        format.html { redirect_to course_url(@course) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(course_url(@course)) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /course_modules/1 or /course_modules/1.json
  def update
    authorize @course_module
    if @course_module.update(course_module_params)      
      flash[:notice] = I18n.t('course.module_updated')

      respond_to do |format|
        format.html { redirect_to course_module_url(@course, @course_module) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(course_module_url(@course, @course_module)) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /course_modules/1 or /course_modules/1.json
  def destroy
    authorize @course_module
    @course_module.destroy!
    service = Courses::ManagementService.instance
    service.update_module_ordering(@course, @course_module, :destroy)

    redirect_to course_url(@course), notice: I18n.t('course.module_deleted')
  end

  def moveup
    authorize @course_module
    service = Courses::ManagementService.instance
    service.update_module_ordering(@course, @course_module, :up)

    redirect_to course_url(@course)
  end

  def movedown
    authorize @course_module
    service = Courses::ManagementService.instance
    service.update_module_ordering(@course, @course_module, :down)

    redirect_to course_url(@course)
  end

  def summary
    authorize @course_module
    @enrollment = current_user.get_enrollment_for(@course)
  end

  def redo_quiz
    authorize @course_module
    @enrollment = current_user.get_enrollment_for(@course)
    service = Courses::ManagementService.instance
    service.redo_quiz(@course_module, @enrollment)
    redirect_to course_module_quiz_path(@course, @course_module, @course_module.first_quiz)
  end

  private

  def set_course_module
    @course_module = @course.course_modules.find(params[:id])
  end

  def set_course
    @course = Course.find(params[:course_id])
  end

  # Only allow a list of trusted parameters through.
  def course_module_params
    params.require(:course_module).permit(:title)
  end
end
