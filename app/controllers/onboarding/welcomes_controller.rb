# frozen_string_literal: true

class Onboarding::WelcomesController < ApplicationController
  layout 'onboarding'

  skip_before_action :proceed_to_onboarding_steps

  def new
  end
  def set_name_and_phone
    render turbo_stream: turbo_stream.replace("onboarding-frame", partial: "onboarding/welcomes/set_name_and_phone")
  end

  def set_dob_and_gender
  end

  def set_preferred_language
  end
  def set_password
  end

  def update
    steps = %w[set_name_and_phone set_dob_and_gender set_language set_password]
    step_index = steps.index(params[:step])

    if current_user.update(user_params)
      redirect_to action: steps[step_index + 1].to_sym
    else
      render turbo_stream: turbo_stream.replace("onboarding-frame", partial: "onboarding/welcomes/#{steps[step_index]}")
    end
  end

  def update_password
    if current_user.update(password_params)
      sign_in(current_user, bypass: true)
      # current_user.activate
      # EVENT_LOGGER.publish_active_user_count(resource)
      redirect_to all_set_onboarding_welcome_path
    else
      render turbo_stream: turbo_stream.replace("onboarding-frame", partial: "onboarding/welcomes/set_password")
    end
  end

  def all_set
    @after_onboarding_path =
      if current_user.is_admin?
        after_sign_in_path_for(current_user)
      elsif current_user.is_manager?
        team_path
      else
        # learners
        courses_path
      end
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone, :dob, :gender, :preferred_local_language)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end