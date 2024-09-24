# frozen_string_literal: true

class MoveAboutPartnerToActionText < ActiveRecord::Migration[7.1]
  def change
    LearningPartner.all.find_each do |partner|
      partner.update(content: partner.about)
    end
  end
end
