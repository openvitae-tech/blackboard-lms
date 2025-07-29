# frozen_string_literal: true

class ProgramsController < ApplicationController
  include SearchContextHelper

  before_action :set_learning_partner
  before_action :set_program, except: %i[new index create]


  def new
    authorize :program
    @program = @learning_partner.programs.new
    load_filtered_courses
  end

  def index
    authorize :program
    @programs = @learning_partner.programs
  end

  def create
    authorize :program
    @program = @learning_partner.programs.new(name: params[:name], courses: selected_courses.includes(:tags, :banner_attachment))

    if @program.save
      redirect_to programs_path, notice: t("resource.created", resource_name: "Program")
    else
      load_filtered_courses
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @program
    @courses = @program.courses.includes(:tags, :banner_attachment)
  end

  def edit
    authorize @program
    load_unassigned_courses
  end

  def update
    authorize @program
    merged_courses = @program.courses | selected_courses

    if @program.update(name: params[:program][:name], courses: merged_courses)
      redirect_to program_path(@program), notice: t("resource.updated", resource_name: "Program")
    else
      load_unassigned_courses
      render :edit, status: :unprocessable_entity
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
  end

  private

  def set_learning_partner
    @learning_partner = LearningPartner.find(current_user.learning_partner_id)
  end

  def set_program
    @program = @learning_partner.programs.find(params[:id])
  end

  def selected_courses
    Course.where(id: params[:course_ids])
  end

  def load_filtered_courses
    @courses = filter_courses.page(params[:page]).per(Course::PER_PAGE_LIMIT)
  end

  def load_unassigned_courses
    @unassigned_courses = filter_courses.where.not(id: @program.course_ids)
                                        .page(params[:page])
                                        .per(Course::PER_PAGE_LIMIT)
  end

  def filter_courses
    @search_context = build_search_context(context: SearchContext::COURSE_LISTING)
    Courses::FilterService.new(current_user, @search_context).filter.records
  end
end
