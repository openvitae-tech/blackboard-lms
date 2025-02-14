class ScormsController < ApplicationController
  before_action :set_course
  before_action :set_learning_partners, only: :new

  def new
    authorize :scorm
    @scorm = Scorm.new
  end

  def create
    authorize :scorm
    @download_link = "#{request.original_url}/download?learning_partner=#{scorm_params[:learning_partner_id]}"
  end

  def download
    authorize :scorm
    scorm = Scorm.find_or_create_by!(learning_partner_id: params[:learning_partner])
    course_object = ScormAdapter.new(@course, scorm.token).process

    file = ScormPackage::Packaging::Generator.new(course_object).generate

    send_data file, type: "application/zip", filename: "#{@course.title}_scorm.zip"
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_learning_partners
    @learning_partners = LearningPartner.all
  end

  def scorm_params
    params.require(:scorm).permit(:learning_partner_id)
  end
end
