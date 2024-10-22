# frozen_string_literal: true

class QuizzesController < ApplicationController
  before_action :set_course
  before_action :set_course_module
  before_action :set_quiz, only: %i[show edit update destroy submit_answer moveup movedown]

  # GET /quizzes or /quizzes.json
  # GET /quizzes/1 or /quizzes/1.json
  def show
    authorize @quiz
    @quizzes = helpers.quizzes_in_order(@course_module)
    @enrollment = current_user.get_enrollment_for(@course) if current_user.enrolled_for_course?(@course)
  end

  # GET /quizzes/new
  def new
    authorize Quiz
    @quiz = @course_module.quizzes.new
  end

  # GET /quizzes/1/edit
  def edit
    authorize @quiz
  end

  # POST /quizzes or /quizzes.json
  def create
    authorize Quiz
    @quiz = @course_module.quizzes.new(quiz_params)
    service = CourseManagementService.instance

    respond_to do |format|
      if @quiz.save
        service.update_quiz_ordering!(@course_module, @quiz, :create)
        format.html do
          redirect_to course_module_path(@course, @course_module), notice: 'Quiz was successfully created.'
        end
        format.json { render :show, status: :created, location: @quiz }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quizzes/1 or /quizzes/1.json
  def update
    authorize @quiz
    respond_to do |format|
      if @quiz.update(quiz_params)
        format.html do
          redirect_to course_module_path(@course, @course_module), notice: 'Quiz was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @quiz }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quizzes/1 or /quizzes/1.json
  def destroy
    authorize @quiz
    @quiz.destroy!
    service = CourseManagementService.instance
    service.update_quiz_ordering!(@course_module, @quiz, :destroy)

    respond_to do |format|
      format.html do
        redirect_to course_module_path(@course, @course_module), notice: 'Quiz was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  def submit_answer
    authorize @quiz
    enrollment = current_user.get_enrollment_for(@course)
    CourseManagementService.instance.record_answer!(enrollment, @quiz, answer_params[:answer].downcase)
    next_quiz = @course_module.next_quiz(@quiz)
    next_path = if next_quiz.blank?
                  # TODO: Show quiz summary page
                  course_path(@course)
                else
                  course_module_quiz_path(@course,
                                          @course_module, next_quiz)
                end
    redirect_to next_path
  end

  def moveup
    authorize @quiz
    service = CourseManagementService.instance
    service.update_quiz_ordering!(@course_module, @quiz, :up)

    respond_to do |format|
      format.html { redirect_to course_module_path(@course, @course_module) }
      format.json { head :no_content }
    end
  end

  def movedown
    authorize @quiz
    service = CourseManagementService.instance
    service.update_quiz_ordering!(@course_module, @quiz, :down)

    respond_to do |format|
      format.html { redirect_to course_module_path(@course, @course_module) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_quiz
    @quiz = @course_module.quizzes.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def quiz_params
    params.require(:quiz).permit(:question, :option_a, :option_b, :option_c, :option_d, :answer)
  end

  def answer_params
    params.require(:quiz).permit(:answer)
  end

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_course_module
    @course_module = @course.course_modules.find(params[:module_id])
  end

  def set_lesson
    @quiz = @course_module.quizzes.find(params[:id])
  end
end
