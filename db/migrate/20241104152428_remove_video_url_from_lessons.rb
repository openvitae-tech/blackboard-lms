class RemoveVideoUrlFromLessons < ActiveRecord::Migration[7.2]
  def change
    remove_column :lessons, :video_url
  end
end
