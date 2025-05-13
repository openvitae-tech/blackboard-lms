class UpdateUserStateForVerifiedUsers < ActiveRecord::Migration[7.2]
  def up
    User.where(state: 'unverified').where.not(confirmed_at: nil).update_all(state: 'active')
  end

  def down

  end
end
