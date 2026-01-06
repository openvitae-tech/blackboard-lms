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
    @question = @course.questions.build(question_attributes)
    if @question.save
      flash.now[:notice] = I18n.t('question.notice.create')
    else
      @question.options.fill("", @question.options.length...5)
    end
  end

  def edit
    authorize @question
    render partial: "form_modal", locals: { course: @course, question: @question }
  end

  def update
    authorize @question

    if @question.update(question_attributes)
      flash.now[:notice] = I18n.t("question.notice.update")
    else
      @question.options.fill("", @question.options.length...5)
    end    
  end

  def destroy
    authorize @question
    @question.destroy!
    flash.now[:notice] = I18n.t("question.notice.destroy")
    render turbo_stream: turbo_stream.refresh(request_id: nil)
  end

  def generate
    authorize :question
    GenerateQuestionsJob.perform_async(@course.id, current_user.id, course_questions_path(@course))
    flash.now[:notice] = I18n.t("notifications.course.questions.generate_start")
  end

  def verify
    authorize @question
    @question.verify
    flash[:notice] = I18n.t("question.notice.verify")
    render turbo_stream: turbo_stream.refresh(request_id: nil)
  end

  def unverify
    authorize @question
    @question.unverify
    flash[:notice] = I18n.t("question.notice.unverify")
    render turbo_stream: turbo_stream.refresh(request_id: nil)
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_question
    @question = @course.questions.find(params[:id])
  end

  def build_new_question
    @question = Question.new options: Array.new(5, "")
  end

  def build_question_bank
    @questions_bank = QuestionsBank.new(@course.questions.order(:created_at))
  end

  def question_attributes
    question_params = {content: params[:content], options: params[:options].select(&:present?)}

    correct_indices = params[:answers_indices]&.map(&:to_i) || []
    answers = correct_indices.map { |index| question_params[:options][index] }.select(&:present?)
    question_params.merge(answers: answers)
  end
end
