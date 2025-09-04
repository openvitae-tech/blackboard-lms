class CreateCertificateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :certificate_templates do |t|
      t.string :name, null: false
      t.text :html_content, null: false
      t.boolean :active, default: false, null: false

      t.references :learning_partner, null: false, foreign_key: true
      t.timestamps
    end
  end
end
