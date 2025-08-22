class AddSupportedCountriesColumnToLearningPartner < ActiveRecord::Migration[8.0]
  def change
    add_column :learning_partners, :supported_countries, :text, array: true, default: [], null: false
  end
end
