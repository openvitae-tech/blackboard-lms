class AddVideoPublishedAtToLocalContents < ActiveRecord::Migration[7.2]
  def change
    add_column :local_contents, :video_published_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }

    LocalContent.find_each do |local_content|
      local_content.update!(:video_published_at, local_content.updated_at)
    end
  end
end
