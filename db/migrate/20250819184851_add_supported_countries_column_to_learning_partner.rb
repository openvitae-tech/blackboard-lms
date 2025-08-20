class AddSupportedCountriesColumnToLearningPartner < ActiveRecord::Migration[8.0]
  def change
    add_column :learning_partners, :supported_countries, :text, array: true, default: [], null: false

    LearningPartner.reset_column_information
    LearningPartner.update_all(supported_countries: AVAILABLE_COUNTRIES[:india][:value])
  end
end
