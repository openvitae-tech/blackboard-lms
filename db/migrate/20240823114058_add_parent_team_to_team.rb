# frozen_string_literal: true

class AddParentTeamToTeam < ActiveRecord::Migration[7.1]
  def change
    add_reference :teams, :parent_team, index: true
  end
end
