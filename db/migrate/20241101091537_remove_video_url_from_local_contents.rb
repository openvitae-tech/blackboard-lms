class RemoveVideoUrlFromLocalContents < ActiveRecord::Migration[7.2]
  def change
    remove_column :local_contents, :video_url
  end
end
