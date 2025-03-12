class ImpersonationsController < ApplicationController

  def create
    authorize :impersonation
    learning_partner = LearningPartner.find(params[:id])

    service = Impersonations::FindOrCreateSupportUserService.instance
    support_user = service.find_or_create_user(learning_partner)
    if fetch_impersonated_user(support_user.id).present?
      redirect_to learning_partner_path(learning_partner), notice: "Already impersonating"
    else
      sign_in support_user

      store_impersonated_user(support_user.id, {impersonator_id: current_user.id, impersonating: true}.to_json)
      redirect_to after_sign_in_path_for(support_user)
    end
  end

  def destroy
    authorize :impersonation
    impersonation_data = JSON.parse(fetch_impersonated_user(current_user.id))

    impersonator = User.find(impersonation_data["impersonator_id"])
    sign_in impersonator

    destroy_impersonation(current_user.id)
    redirect_to after_sign_in_path_for(impersonator), notice: "You have exited impersonation mode and are now logged in as admin."
  end
end
