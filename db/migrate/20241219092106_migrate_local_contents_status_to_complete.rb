class MigrateLocalContentsStatusToComplete < ActiveRecord::Migration[7.2]
  def up
    LocalContent.update_all(status: 'complete')
  end
end
