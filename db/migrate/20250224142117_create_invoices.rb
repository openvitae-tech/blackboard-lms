class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.integer :billable_days, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :paid_at
      t.datetime :bill_date, null: false
      t.string :status, null: false, default: "pending"
      t.integer :active_users, null: false
      t.references :learning_partner, null: false, foreign_key: true

      t.timestamps
    end

    execute "ALTER SEQUENCE invoices_id_seq RESTART WITH 1000;"
  end
end
