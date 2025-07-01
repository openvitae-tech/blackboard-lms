class ImpersonationsController < ApplicationController

  def create
    authorize :impersonation
    learning_partner = LearningPartner.find(params[:id])
    service = Impersonations::FindOrCreateSupportUserService.instance
    support_user = service.find_or_create_user(learning_partner)
    sign_in support_user

    store_impersonated_user(support_user.id, {impersonator_id: current_user.id, impersonating: true}.to_json)
    redirect_to after_sign_in_path_for(support_user), notice: t("impersonation.logged_in_as_support_user")
  end

  def destroy
    authorize :impersonation
    impersonation_data = JSON.parse(fetch_impersonated_user(current_user.id))

    impersonator = User.find(impersonation_data["impersonator_id"])
    sign_in impersonator

    redirect_to after_sign_in_path_for(impersonator), notice: t("impersonation.stop_and_login")
  end
end
