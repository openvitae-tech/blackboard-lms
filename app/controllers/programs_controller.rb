# frozen_string_literal: true

class ProgramsController < ApplicationController
  include PaginationConcern
  include SearchContextHelper

  before_action :set_learning_partner
  before_action :set_program, except: %i[new index create]

  def new
    authorize :program
    @program = @learning_partner.programs.new
  end

  def index
    authorize :program
    @programs = @learning_partner.programs
  end

  def show
    authorize @program
    @courses = @program.courses.includes(:tags, :banner_attachment).page(params[:page]).per(Program::DEFAULT_PER_PAGE_SIZE)
  end

  def create
    authorize :program
    @program = @learning_partner.programs.new(program_params)

    if @program.save
      flash[:success] = t("resource.created", resource_name: "Program")
    else
      render :new, status: :unprocessable_entity
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
    else
      render :edit, status: :unprocessable_entity
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

    selected_courses.each do |course|
      @program.program_courses.create!(course: course)
    end

    respond_to do |format|
      format.turbo_stream do
        flash[:success] = t("resource.updated", resource_name: "Program")
        render turbo_stream: turbo_stream.redirect_to(program_path(@program))
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
    flash.discard
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
        render turbo_stream: turbo_stream.redirect_to(program_path(@program, page: get_current_page(record: @program.courses, page: params[:page])))
      end
    end
  end

  private

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
    @courses = filter_courses.page(params[:page]).per(Course::PER_PAGE_LIMIT)
  end

  def filter_courses
    @search_context = build_search_context(context: SearchContext::PROGRAM, resource: @program)
    Courses::FilterService.new(current_user, @search_context).filter.records
  end
end
