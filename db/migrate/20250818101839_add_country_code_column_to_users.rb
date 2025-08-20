class AddCountryCodeColumnToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :country_code, :string

    User.reset_column_information
    User.where.not(phone: [nil, ""]).update_all(country_code: AVAILABLE_COUNTRIES[:india][:code])
  end
end
