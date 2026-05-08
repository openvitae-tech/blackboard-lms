# frozen_string_literal: true

class ProgramsController < ApplicationController
  include PaginationConcern
  include SearchContextHelper

  before_action :set_learning_partner
  before_action :set_program, except: %i[new index explore create list choose]
  before_action :set_learner_mode, only: %i[show update add_courses create_courses bulk_destroy_courses]
  before_action :set_programs_active_nav, only: %i[explore show]

  def new
    authorize :program
    @program = @learning_partner.programs.new
  end

  def index
    authorize :program
    @programs = @learning_partner.programs.filter_by_name(params[:term]).order(created_at: :desc).page(params[:page]).per(Program::DEFAULT_PER_PAGE_SIZE)
  end

  def explore
    authorize :program
    @programs = current_user.learning_partner.programs
    @programs = @programs.filter_by_name(params[:term]).page(params[:page]).per(Program::DEFAULT_PER_PAGE_SIZE)

    search_context = SearchContext.new context: :home_page, type: SearchContext::INCOMPLETE
    @courses = Courses::FilterService.new(current_user, search_context).filter.records
                                    .preload(:tags, :banner_attachment)
  end

  def show
    authorize @program
    @courses = @program.courses.includes(:tags, :banner_attachment).page(params[:page]).per(Course::PER_PAGE_LIMIT)
    @enrollments_by_course_id = current_user.enrollments.indexed_by_course(@courses)
  end

  def create
    authorize :program
    @program = @learning_partner.programs.new(program_params)

    if @program.save
      flash[:success] = t("resource.created", resource_name: "Program")
      @programs = @learning_partner.programs.filter_by_name(params[:term]).order(created_at: :desc).page(1).per(Program::DEFAULT_PER_PAGE_SIZE)
    else
      render :new, status: :unprocessable_content
    end
    flash.discard
  end

  def edit
    authorize @program
  end

  def update
    authorize @program
    if @program.update(program_params)
      flash[:success] = t("resource.updated", resource_name: "Program")
      @courses = @program.courses.includes(:tags, :banner_attachment).page(params[:page]).per(Course::PER_PAGE_LIMIT)
      @enrollments_by_course_id = current_user.enrollments.indexed_by_course(@courses)
      @programs = @learning_partner.programs.filter_by_name(params[:term]).order(created_at: :desc).page(params[:page]).per(Program::DEFAULT_PER_PAGE_SIZE)
    else
      render :edit, status: :unprocessable_content
    end
    flash.discard
  end

  def add_courses
    authorize @program
     @tags = Tag.load_tags
    load_unassigned_courses
  end

  def create_courses
    authorize @program

    errors = []

    selected_courses.each do |course|
      program_course = @program.program_courses.build(course: course)

      unless program_course.save
        errors << program_course.errors.full_messages.to_sentence
      end
    end

    if errors.empty?
      flash[:success] = t("resource.updated", resource_name: "Program")
    else
      flash[:error] = errors.join(", ")
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.redirect_to(program_path(@program, mode: Program::MANAGER_MODE))
      end
    end
  end

  def confirm_destroy
    authorize @program
  end

  def destroy
    authorize @program
    @program.destroy!
    flash[:success] = t("resource.deleted", resource_name: "Program")
    @programs = @learning_partner.programs.filter_by_name(params[:term]).order(created_at: :desc).page(params[:page]).per(Program::DEFAULT_PER_PAGE_SIZE)
    flash.discard
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to programs_path }
    end
  end

  def confirm_bulk_destroy_courses
    authorize @program
    @course_ids = params[:course_ids]
  end

  def bulk_destroy_courses
    authorize @program
    course_ids = params[:course_ids].reject(&:blank?)

    if course_ids.present?
      @program.program_courses.where(course_id: course_ids).destroy_all
      flash[:success] = t("resource.deleted", resource_name: "Courses")
    else
      flash[:alert] = t("resource.not_found", resource_name: "Courses")
    end
    flash.discard
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.redirect_to(program_path(@program, page: get_current_page(record: @program.courses, page: params[:page]), mode: params[:mode]))
      end
    end
  end

  def list
    authorize :program
    @programs = @learning_partner.programs
    @program_options = @programs.map { |prog| [prog.name, prog.id] }
  end

  def choose
    authorize :program

    program = @learning_partner.programs.find(params[:program_id])
    service = Courses::ProgramEnrollmentService.new(current_user, program)

    begin
      service.enroll!
    rescue StandardError => e
      Sentry.capture_message(e.message, level: :error)
      flash.now[:alert] = "Failed to enroll in some courses: #{e.message}"
    end

    flash.now[:success] = I18n.t('programs.choose_success')
  end

  private

  def set_learner_mode
    raise ActiveRecord::RecordNotFound if params[:mode] == Program::MANAGER_MODE && !current_user.privileged_user?

    @learner_mode = params[:mode].blank? || params[:mode] == Program::LEARNER_MODE
  end

  def set_programs_active_nav
    @active_nav = case action_name
    when 'explore' then 'courses'
    when 'show' then @learner_mode ? 'courses' : 'programs'
    end
  end

  def set_learning_partner
    @learning_partner = LearningPartner.find(current_user.learning_partner_id)
  end

  def set_program
    @program = @learning_partner.programs.find(params[:id])
  end

  def program_params
    params.require(:program).permit(:name)
  end

  def selected_courses
    Course.where(id: params[:course_ids])
  end

  def load_unassigned_courses
    @courses = filter_courses.includes(:tags, banner_attachment: :blob).page(params[:page]).per(Course::PER_PAGE_LIMIT)
  end

  def filter_courses
    @search_context = build_search_context(context: SearchContext::PROGRAM, resource: @program)
    Courses::FilterService.new(current_user, @search_context).filter.records
  end
end
