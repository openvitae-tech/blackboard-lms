# frozen_string_literal: true

class InvoicesController < ApplicationController
  before_action :set_learning_partner

  def index
    #add permission only for admin and owner
    @invoices = @learning_partner.invoices.order(bill_date: :desc)
  end

  private

  def set_learning_partner
    if current_user.is_admin?
      @learning_partner = LearningPartner.find(params[:id])
    else
      @learning_partner = current_user.learning_partner
    end
  end
end
