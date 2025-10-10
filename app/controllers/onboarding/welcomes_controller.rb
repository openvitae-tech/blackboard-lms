# frozen_string_literal: true

class Onboarding::WelcomesController < ApplicationController
  layout 'onboarding'

  skip_before_action :proceed_to_onboarding_steps
  before_action :skip_onboarding_for_active_users, except: :all_set

  def new
  end
  def set_name_and_email
    render turbo_stream: turbo_stream.replace("onboarding-frame", partial: "onboarding/welcomes/set_name_and_email")
  end

  def set_dob_and_gender
  end

  def set_preferred_language
  end

  def set_learning_program
    @programs = current_user.learning_partner&.programs
  end
  def set_password
  end

  def update
    steps = %w[set_name_and_email set_dob_and_gender set_language set_learning_program set_password]
    step_index = steps.index(params[:step])

    done = if params[:step] == 'set_learning_program'
      assign_program_to_user(user_params[:program_id])
      true
    else
      current_user.update(user_params)
    end

    if done
      redirect_to action: steps[step_index + 1].to_sym
    else
      render turbo_stream: turbo_stream.replace("onboarding-frame", partial: "onboarding/welcomes/#{steps[step_index]}")
    end
  end

  def update_password
    if current_user.update(password_params)
      bypass_sign_in(current_user)
      current_user.activate
      EVENT_LOGGER.publish_active_user_count(current_user)
      redirect_to all_set_onboarding_welcome_path
    else
      render turbo_stream: turbo_stream.replace("onboarding-frame", partial: "onboarding/welcomes/set_password")
    end
  end

  def all_set
    @after_onboarding_path =
      if current_user.is_admin?
        after_sign_in_path_for(current_user)
      elsif current_user.is_manager? || current_user.is_owner?
        team_path(current_user.team)
      else
        # learners
        courses_path
      end
  end

  private

  def skip_onboarding_for_active_users
    redirect_to after_sign_in_path_for(current_user) if current_user.active?
  end

  def user_params
    params.require(:user).permit(:name, :email, :dob, :gender, :preferred_local_language, :program_id)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def assign_program_to_user(program_id)
    return if program_id.blank?
    program = Program.find(program_id)
    service = CourseManagementService.instance

    program.courses.each do |course|
      service.enroll!(current_user, course)
    end
  end
end