class QuestionsController < ApplicationController
  include CommonsHelper

  before_action :set_course
  before_action :set_question, only: %i[edit update destroy verify unverify]
  before_action :build_question_bank, only: %i[index destroy verify unverify]
  before_action :build_new_question, only: %i[new]

  def index
    authorize :question
  end

  def new
    authorize :question
    render partial: "form_modal", locals: { course: @course, question: @question }
  end

  def create
    authorize :question
    question_params = {content: params[:content], options: params[:options].select(&:present?)}

    correct_indices = params[:answers_indices]&.map(&:to_i) || []
    answers = correct_indices.map { |index| question_params[:options][index] }.select(&:present?)
    @question = @course.questions.build(question_params.merge(answers: answers))
    if @question.save
      render turbo_stream: turbo_stream.redirect_to(
        course_questions_path(@course, tab: params[:tab], page: params[:page])
        ), notice: I18n.t('question.notice.create')
    else
      @question.options.fill("", @question.options.length...4)
      render turbo_stream: turbo_stream.replace("modal",
                                                partial: "form_modal",
                                                locals: { course: @course, question: @question })
    end    
  end

  def edit
    authorize @question
    render partial: "form_modal", locals: { course: @course, question: @question }
  end

  def update
    authorize @question
    question_params = {content: params[:content], options: params[:options].select(&:present?)}

    correct_indices = params[:answers_indices]&.map(&:to_i) || []
    answers = correct_indices.map { |index| question_params[:options][index] }

    if @question.update(question_params.merge(answers: answers))
      render turbo_stream: turbo_stream.redirect_to(
          course_questions_path(@course, tab: params[:tab], page: params[:page])
        ), notice: I18n.t('question.notice.update')
    else
      @question.options.fill("", @question.options.length...4)
      render turbo_stream: turbo_stream.replace("modal",
                                                partial: "form_modal",
                                                locals: { course: @course, question: @question })
    end    
  end

  def destroy
    authorize @question
    @question.destroy!
    redirect_to course_questions_path(@course, tab: params[:tab], page: params[:page]), 
                notice: I18n.t('question.notice.destroy')
  end

  def generate
    authorize :question
    GenerateQuestionsJob.perform_async(@course.id, current_user.id, course_questions_path(@course))

    redirect_to course_questions_path(@course, tab: params[:tab], page: params[:page]),
                notice: I18n.t('notifications.course.questions.generate_start')
  end

  def verify
    authorize @question
    @question.verify
    flash[:notice] = I18n.t("question.notice.verify")
    redirect_to course_questions_path(@course, tab: params[:tab], page: params[:page])
  end

  def unverify
    authorize @question
    @question.unverify
    flash[:notice] = I18n.t("question.notice.verify")
    redirect_to course_questions_path(@course, tab: params[:tab], page: params[:page])
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_question
    @question = @course.questions.find(params[:id])
  end

  def build_new_question
    @question = Question.new options: Array.new(4, "")
  end

  def build_question_bank
    @questionsBank = QuestionsBank.new(@course.questions.order(:created_at))
  end
end
