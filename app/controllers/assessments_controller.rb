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

    @current_index = @assessment.current_question_index
    @question_data = @assessment.questions[@current_index]
    
    @question_statuses = @assessment.questions.map.with_index do |q_data, index|
      q_id = q_data['id'].to_s
      answer = @assessment.responses[q_id]

      status = if index == @current_index
                 :current
               elsif answer.present?
                 :answered
               elsif @assessment.responses.key?(q_id) && answer.blank?
                 :skipped
               else
                 :not_answered
               end
      { index: index, status: status }
    end

    @counts = {
      answered: @question_statuses.count { |s| s[:status] == :answered },
      skipped: @question_statuses.count { |s| s[:status] == :skipped },
      not_answered: @question_statuses.count { |s| s[:status] == :not_answered }
    }
    render layout: "assessment"
  end

  def update
    authorize @assessment
    action = params[:commit] || ""
    if action.include?("Save")
      q_id = params[:assessment][:question_id].to_s
      answers = params[:assessment][:answer] || [] 
      @assessment.responses[q_id] = Array.wrap(answers)
    elsif action == "Skip and Next"
      q_id = params[:assessment][:question_id].to_s
      @assessment.responses[q_id] = [] unless @assessment.responses.key?(q_id)
    end

    new_index = @assessment.current_question_index
    
    if action.include?("Next")
      new_index += 1 if new_index < @assessment.questions.count - 1
    elsif action == "Previous"
      new_index -= 1 if new_index > 0
    elsif params[:jump_to_index]
      new_index = params[:jump_to_index].to_i
    end

    @assessment.current_question_index = new_index
    @assessment.save(validate: false)

    if action == "Save & Submit Assessment"
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