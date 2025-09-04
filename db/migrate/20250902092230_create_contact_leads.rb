class CreateContactLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_leads do |t|
      t.string :phone, null: false
      t.string :country_code, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
