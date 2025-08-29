class DataFillInCountryCodes < ActiveRecord::Migration[8.0]
  def up
    User.where.not(phone: nil).update_all(country_code: "+91")
    LearningPartner.update_all(supported_countries: ["india"])
  end

  def down

  end
end
