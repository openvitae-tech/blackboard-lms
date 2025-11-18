# frozen_string_literal: true

class LearningPartnersController < ApplicationController
  before_action :set_learning_partner, only: %i[show edit update destroy activate deactivate]

  # GET /learning_partners or /learning_partners.json
  def index
    authorize :learning_partner
    @learning_partners = LearningPartner.includes([:logo_attachment, :payment_plan]).order(:name).page(params[:page])
  end

  # GET /learning_partners/1 or /learning_partners/1.json
  def show
    authorize :learning_partner
    @metrics = PartnerMetrics.new(@learning_partner)
    @members = Users::FilterService.new(@learning_partner.parent_team)
                                   .filter
                                   .page(params[:page])
                                   .per(User::PER_PAGE_LIMIT)
  end

  # GET /learning_partners/new
  def new
    authorize :learning_partner
    @learning_partner = LearningPartner.new
  end

  # GET /learning_partners/1/edit
  def edit
    authorize :learning_partner
  end

  # POST /learning_partners or /learning_partners.json
  def create
    authorize :learning_partner

    @learning_partner = LearningPartner.new(learning_partner_params)

    service = PartnerOnboardingService.instance
    status = service.create_partner(@learning_partner)

    respond_to do |format|
      if status == 'ok'
        EVENT_LOGGER.publish_onboarding_initiated(current_user, @learning_partner)
        format.html do
          redirect_to new_learning_partner_payment_plan_path(@learning_partner), notice: t("resource.created", resource_name: "Learning Partner")
        end
        format.json { render :show, status: :created, location: @learning_partner }
      else
        format.html { render :new, status: :bad_request }
        format.json { render json: @learning_partner.errors, status: :bad_request }
      end
    end
  end

  # PATCH/PUT /learning_partners/1 or /learning_partners/1.json
  def update
    authorize :learning_partner

    respond_to do |format|
      if @learning_partner.update(learning_partner_params)
        format.html do
          redirect_to learning_partner_path(@learning_partner), notice: 'Learning partner was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @learning_partner }
      else
        format.html { render :edit, status: :bad_request }
        format.json { render json: @learning_partner.errors, status: :bad_request }
      end
    end
  end

  # DELETE /learning_partners/1 or /learning_partners/1.json
  def destroy
    authorize :learning_partner

    @learning_partner.destroy!

    respond_to do |format|
      format.html { redirect_to learning_partners_url, notice: 'Learning partner was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def activate
    authorize @learning_partner
    @learning_partner.activate
    redirect_to @learning_partner, notice: 'Learning partner is re-activated.'
  end

  def deactivate
    authorize @learning_partner
    @learning_partner.deactivate
    terminate_impersonation

    redirect_to @learning_partner, notice: 'Learning partner is deactivated.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_learning_partner
    @learning_partner = LearningPartner.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def learning_partner_params
    params.require(:learning_partner).permit(:name, :about, :logo, :banner, :max_user_count, supported_countries: [])
  end

  def authorize_admin!
    authorize :learning_partner
  end

  def terminate_impersonation
    impersonated_user = @learning_partner.users.find_by(role: "support")
    destroy_impersonation(impersonated_user.id) if impersonated_user.present?
  end
end
