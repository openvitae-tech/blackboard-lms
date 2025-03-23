class AddVideoPublishedAtToLocalContents < ActiveRecord::Migration[7.2]
  def up
    add_column :local_contents, :video_published_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }

    LocalContent.find_each do |local_content|
      local_content.update_column(:video_published_at, local_content.updated_at)
    end
  end

  def down
    remove_column :local_contents, :video_published_at
  end
end
