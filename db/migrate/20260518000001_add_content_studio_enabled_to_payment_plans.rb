# frozen_string_literal: true

class AddContentStudioEnabledToPaymentPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :payment_plans, :content_studio_enabled, :boolean, default: false, null: false
  end
end
