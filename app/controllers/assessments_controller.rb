class AssessmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: :intro
  before_action :store_user_location!, only: :show 
  before_action :authenticate_user!, except: :intro
  before_action :set_assessment
  before_action :set_course_certificate, only: %i[show result]
  before_action :generate_certificate, only: :show
  before_action :display_result_when_completed, except: %i[result retry]
  
  def intro
  end

  def show
    authorize @assessment
    @assessment.start! if @assessment.pending?

    @presenter = Assessments::PresenterService.new(@assessment)

    render layout: "assessment"
  end

  def update
    authorize @assessment

    service = Assessments::UpdateService.new(@assessment, params).call

    if service.submit?
      redirect_to result_assessment_path(id: @assessment.encoded_id)
    else
      redirect_to assessment_path(id: @assessment.encoded_id)
    end    
  end

  def result
    authorize @assessment
    @assessment.complete! unless @assessment.completed?
  end

  def retry
    authorize @assessment
    @assessment.retry!
    redirect_to intro_assessment_path(id: @assessment.encoded_id)
  end

  private

  def set_assessment
    decoded_str = Base64.decode64(params[:id])
    @assessment = Assessment.find(decoded_str.split('-')[1])
  end

  def set_course_certificate
    @certificate = CourseCertificate.find_by(user: current_user, course: @assessment.course)
  end

  def display_result_when_completed
    if @assessment.completed? || @assessment.time_taken >= 20
      redirect_to(result_assessment_path(id: @assessment.encoded_id)) && return
    end    
  end

  def generate_certificate
    return unless current_user.learning_partner.active_certificate_template.present?

    key = "GenerateCertificate:#{@assessment.course_id}:#{current_user.id}"

    Rails.cache.fetch(key, expires_in: 1.hour) do
      GenerateCourseCertificateJob.perform_async(@assessment.course_id, current_user.id,
                                                 current_user.learning_partner.active_certificate_template.id)
    end
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end  
end