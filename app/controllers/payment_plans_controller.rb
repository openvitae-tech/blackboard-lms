# frozen_string_literal: true

class PaymentPlansController < ApplicationController
  before_action :set_learning_partner
  before_action :set_payment_plan, only: %i[edit update]

  def new
    authorize @learning_partner, policy_class: PaymentPlanPolicy
    @payment_plan = PaymentPlan.default_plan
  end

  def create
    authorize @learning_partner, policy_class: PaymentPlanPolicy

    @payment_plan = @learning_partner.build_payment_plan(payment_plan_params)
    if @payment_plan.save
      EVENT_LOGGER.publish_payment_plan_created(current_user, @learning_partner)
      redirect_to learning_partner_path(@learning_partner), notice: t("resource.created", resource_name: "Payment plan")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @payment_plan ||= PaymentPlan.default_plan
    authorize @payment_plan
  end

  def update
    @payment_plan ||= @learning_partner.build_payment_plan
    authorize @payment_plan

    if @payment_plan.update(payment_plan_params)
      event = @learning_partner.payment_plan.id_previously_changed? ? :publish_payment_plan_created : :publish_payment_plan_updated
      EVENT_LOGGER.send(event, current_user, @learning_partner)
      flash.now[:success] = t("resource.updated", resource_name: "Payment plan")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_learning_partner
    @learning_partner = LearningPartner.find(params[:learning_partner_id])
  end

  def payment_plan_params
    params.require(:payment_plan).permit(:start_date, :end_date, :total_seats, :per_seat_cost)
  end

  def set_payment_plan
    @payment_plan = @learning_partner.payment_plan
  end
end
