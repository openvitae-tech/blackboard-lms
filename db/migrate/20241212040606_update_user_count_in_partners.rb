class UpdateUserCountInPartners < ActiveRecord::Migration[7.2]
  def up
    LearningPartner.all.each do |partner|
      LearningPartner.reset_counters(partner.id, :users)
    end
  end

  def down
    # no rollback needed
  end
end
