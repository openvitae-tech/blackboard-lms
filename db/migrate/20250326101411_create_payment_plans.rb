class CreatePaymentPlans < ActiveRecord::Migration[7.2]
  def up
    create_table :payment_plans do |t|
      t.timestamps
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.integer :total_seats, null: false
      t.decimal :per_seat_cost, null: false
      t.references :learning_partner, null: false, foreign_key: true
    end

    LearningPartner.find_each do |learning_partner|
      learning_partner.create_payment_plan!(
        start_date: Time.zone.now,
        end_date: 1.months.from_now,
        total_seats: PaymentPlan::DEFAULT_TOTAL_SEATS,
        per_seat_cost: PaymentPlan::DEFAULT_PER_SEAT_COST
      )
    end
  end

  def down
    drop_table :payment_plans
  end
end
