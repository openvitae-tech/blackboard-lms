class MaterialsController < ApplicationController
  before_action :set_course
  def index
  end

  def create
    authorize @course, :update?
    all_materials = @course.materials.blobs + Array.wrap(materials_params[:materials])
    if @course.update(materials: all_materials)
      flash[:success] = "Course Materials Uploaded"
      flash.discard
    else
      flash[:error] = @course.errors.full_messages.to_sentence
      flash.discard
      @course.reload
    end
  end

  def destroy
    authorize @course, :update?
    @course.materials.find(params[:id]).purge
    flash[:success] = "Course material deleted"
    flash.discard
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def materials_params
    params.require(:course).permit(materials: [])
  end
end
