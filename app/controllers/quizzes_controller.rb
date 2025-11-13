# frozen_string_literal: true

class QuizzesController < ApplicationController
  before_action :set_course
  before_action :set_course_module
  before_action :set_quiz, only: %i[show edit update destroy submit_answer moveup movedown]

  def show
    authorize @quiz
    if current_user.enrolled_for_course?(@course)
      @enrollment = current_user.get_enrollment_for(@course)
      @answer = @enrollment.get_answer(@quiz) if @enrollment.quiz_answered?(@quiz)
    end
  end

  def new
    authorize Quiz
    @quiz = @course_module.quizzes.new
  end

  def edit
    authorize @quiz
  end

  def create
    authorize Quiz
    @quiz = @course_module.quizzes.new(quiz_params)
    service = CourseManagementService.instance

    if @quiz.save
      service.update_quiz_ordering!(@course_module, @quiz, :create)
      redirect_to course_module_path(@course, @course_module), notice: 'Quiz was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @quiz

    if @quiz.update(quiz_params)
        redirect_to course_module_path(@course, @course_module), notice: 'Quiz was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def generate
    authorize Quiz

    quizzes = Quizzes::GenerationService.new(@course_module).generate_via_ai
    if quizzes.empty?
      redirect_to course_module_path(@course, @course_module), notice: 'Quiz generation via AI failed. Please try again later.'
      return
    end

    quizzes.each do |quiz_data|
      quiz = @course_module.quizzes.new(
        question: quiz_data['question'],
        option_a: quiz_data['options'][0],
        option_b: quiz_data['options'][1],
        option_c: quiz_data['options'][2],
        option_d: quiz_data['options'][3],
        answer: quiz_data['answer_text']
      )
      if quiz.save
        service = CourseManagementService.instance
        service.update_quiz_ordering!(@course_module, quiz, :create)
      else
        Rails.logger.error("Failed to save generated quiz: #{quiz.errors.full_messages.join(', ')}")
      end
    end
    redirect_to course_module_path(@course, @course_module), notice: 'Quizzes were successfully generated via AI.'
  end

  def destroy
    authorize @quiz

    @quiz.destroy!
    service = CourseManagementService.instance
    service.update_quiz_ordering!(@course_module, @quiz, :destroy)
    redirect_to course_module_path(@course, @course_module), notice: 'Quiz was successfully destroyed.'
  end

  def submit_answer
    authorize @quiz
    enrollment = current_user.get_enrollment_for(@course)
    CourseManagementService.instance.record_answer!(enrollment, @quiz, answer_params[:answer].downcase)
    next_quiz = @course_module.next_quiz(@quiz)
    next_path = if next_quiz.blank?
                  summary_course_module_path(@course, @course_module)
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
    redirect_to course_module_path(@course, @course_module)
  end

  def movedown
    authorize @quiz
    service = CourseManagementService.instance
    service.update_quiz_ordering!(@course_module, @quiz, :down)
    redirect_to course_module_path(@course, @course_module)
  end

  private

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
