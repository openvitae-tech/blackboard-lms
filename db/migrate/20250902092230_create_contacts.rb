class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :phone
      t.string :country_code
      t.string :name

      t.timestamps
    end
  end
end
